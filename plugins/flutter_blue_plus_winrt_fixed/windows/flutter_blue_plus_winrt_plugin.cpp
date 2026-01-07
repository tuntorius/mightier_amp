#pragma warning(disable : 4819)

#include "flutter_blue_plus_winrt_plugin.h"
#include "utils.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <Windows.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Devices.Bluetooth.h>
#include <winrt/Windows.Devices.Bluetooth.Advertisement.h>
#include <winrt/Windows.Devices.Bluetooth.GenericAttributeProfile.h>
#include <winrt/Windows.Devices.Enumeration.h>
#include <winrt/Windows.Devices.Radios.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Storage.Streams.h>

#include <memory>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <vector>
#include <exception>
#include <cstdarg>
#include <chrono>

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Devices::Bluetooth;
using namespace Windows::Devices::Bluetooth::Advertisement;
using namespace Windows::Devices::Bluetooth::GenericAttributeProfile;
using namespace Windows::Devices::Enumeration;
using namespace Windows::Devices::Radios;

namespace flutter_blue_plus_winrt {

// Debug Logging Helper
void Log(const char* format, ...) {
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    std::string msg = "[FBP-Win] ";
    msg += buffer;
    msg += "\n";
    OutputDebugStringA(msg.c_str());
}

namespace utils {
std::string to_string(const winrt::hstring& hstr) {
    return winrt::to_string(hstr);
}

template <typename T>
T from_value(const flutter::EncodableValue* value) {
    if (auto* ptr = std::get_if<T>(value)) {
        return *ptr;
    }
    if constexpr (std::is_integral_v<T> && !std::is_same_v<T, bool>) {
        if (auto* ptr64 = std::get_if<int64_t>(value)) {
            return static_cast<T>(*ptr64);
        }
        if (auto* ptr32 = std::get_if<int32_t>(value)) {
            return static_cast<T>(*ptr32);
        }
    }
    return T{};
}

uint64_t mac_to_uint64(const std::string& mac_address) {
    std::stringstream ss(mac_address);
    uint64_t result = 0;
    for (int i = 0; i < 6; ++i) {
        long long byte;
        ss >> std::hex >> byte;
        result = (result << 8) | byte;
        if (i < 5) {
            ss.ignore();
        }
    }
    return result;
}

std::vector<uint8_t> to_vector(const winrt::Windows::Storage::Streams::IBuffer& buffer) {
    auto reader = winrt::Windows::Storage::Streams::DataReader::FromBuffer(buffer);
    std::vector<uint8_t> data(reader.UnconsumedBufferLength());
    if (!data.empty()) {
        reader.ReadBytes(data);
    }
    return data;
}

std::string to_uuid_string(const winrt::guid& uuid) {
    std::string uuid_str_with_braces = winrt::to_string(winrt::to_hstring(uuid));
    std::string full_uuid;

    if (uuid_str_with_braces.length() >= 2 && uuid_str_with_braces.front() == '{' && uuid_str_with_braces.back() == '}') {
        full_uuid = uuid_str_with_braces.substr(1, uuid_str_with_braces.length() - 2);
    } else {
        full_uuid = uuid_str_with_braces;
    }

    std::transform(full_uuid.begin(), full_uuid.end(), full_uuid.begin(),
                   [](unsigned char c){ return static_cast<char>(std::tolower(c)); });

    if (full_uuid.length() == 36 &&
        full_uuid.substr(0, 4) == "0000" &&
        full_uuid.substr(8) == "-0000-1000-8000-00805f9b34fb") {
        return full_uuid.substr(4, 4);
    }
    return full_uuid;
}

winrt::guid parse_uuid(const std::string& uuid_str) {
    std::string full_uuid = uuid_str;
    if (full_uuid.length() == 4) {
        full_uuid = "0000" + full_uuid + "-0000-1000-8000-00805f9b34fb";
    }
    else if (full_uuid.length() == 8) {
        full_uuid = full_uuid + "-0000-1000-8000-00805f9b34fb";
    }
    
    if (full_uuid.length() > 0 && full_uuid.front() != '{') {
        full_uuid = "{" + full_uuid + "}";
    }

    std::wstring wstr(full_uuid.begin(), full_uuid.end());
    GUID guid;
    if (SUCCEEDED(IIDFromString(wstr.c_str(), &guid))) {
        return winrt::guid(guid);
    }
    return winrt::guid();
}

}  // namespace utils

// --- GATT Helper Members ---

winrt::Windows::Foundation::IAsyncOperation<GattCharacteristic> 
FlutterBluePlusWinrtPlugin::FindCharacteristicInServiceAsync(
    GattDeviceService service,
    int instance_id,
    BluetoothCacheMode cacheMode)
{
    try {
        auto charsResult = co_await service.GetCharacteristicsAsync(cacheMode);
        if (charsResult.Status() == GattCommunicationStatus::Success) {
            for (auto c : charsResult.Characteristics()) {
                if (instance_id != 0 && static_cast<int32_t>(c.AttributeHandle()) == instance_id) {
                    co_return c;
                }
            }
        }

        auto includedResult = co_await service.GetIncludedServicesAsync(cacheMode);
        if (includedResult.Status() == GattCommunicationStatus::Success) {
            for (auto includedService : includedResult.Services()) {
                auto c = co_await FindCharacteristicInServiceAsync(includedService, instance_id, cacheMode);
                if (c) co_return c;
            }
        }
    } catch (...) {}
    co_return nullptr;
}

winrt::Windows::Foundation::IAsyncOperation<GattCharacteristic> 
FlutterBluePlusWinrtPlugin::FindCharacteristicByDescriptorHandleInServiceAsync(
    GattDeviceService service,
    int descriptor_handle,
    BluetoothCacheMode cacheMode)
{
    if (descriptor_handle == 0) co_return nullptr;

    try {
        auto charsResult = co_await service.GetCharacteristicsAsync(cacheMode);
        if (charsResult.Status() == GattCommunicationStatus::Success) {
            for (auto c : charsResult.Characteristics()) {
                 auto descResult = co_await c.GetDescriptorsAsync(cacheMode);
                 if (descResult.Status() == GattCommunicationStatus::Success) {
                     for (auto d : descResult.Descriptors()) {
                         if (static_cast<int32_t>(d.AttributeHandle()) == descriptor_handle) {
                             co_return c;
                         }
                     }
                 }
            }
        }

        auto includedResult = co_await service.GetIncludedServicesAsync(cacheMode);
        if (includedResult.Status() == GattCommunicationStatus::Success) {
            for (auto includedService : includedResult.Services()) {
                auto c = co_await FindCharacteristicByDescriptorHandleInServiceAsync(includedService, descriptor_handle, cacheMode);
                if (c) co_return c;
            }
        }
    } catch (...) {}
    co_return nullptr;
}

winrt::Windows::Foundation::IAsyncOperation<GattCharacteristic> 
FlutterBluePlusWinrtPlugin::GetCharacteristicByHandleAsync(
    BluetoothLEDevice device,
    int instance_id)
{
    auto servicesResult = co_await device.GetGattServicesAsync(BluetoothCacheMode::Cached);
    if (servicesResult.Status() == GattCommunicationStatus::Success) {
        for (auto service : servicesResult.Services()) {
            auto c = co_await FindCharacteristicInServiceAsync(service, instance_id, BluetoothCacheMode::Cached);
            if (c) co_return c;
        }
    }

    servicesResult = co_await device.GetGattServicesAsync(BluetoothCacheMode::Uncached);
    if (servicesResult.Status() == GattCommunicationStatus::Success) {
        for (auto service : servicesResult.Services()) {
            auto c = co_await FindCharacteristicInServiceAsync(service, instance_id, BluetoothCacheMode::Uncached);
            if (c) co_return c;
        }
    }
    co_return nullptr;
}

winrt::Windows::Foundation::IAsyncOperation<GattCharacteristic> 
FlutterBluePlusWinrtPlugin::GetCharacteristicByDescriptorHandleAsync(
    BluetoothLEDevice device,
    int descriptor_handle)
{
    auto servicesResult = co_await device.GetGattServicesAsync(BluetoothCacheMode::Cached);
    if (servicesResult.Status() == GattCommunicationStatus::Success) {
        for (auto service : servicesResult.Services()) {
            auto c = co_await FindCharacteristicByDescriptorHandleInServiceAsync(service, descriptor_handle, BluetoothCacheMode::Cached);
            if (c) co_return c;
        }
    }
    servicesResult = co_await device.GetGattServicesAsync(BluetoothCacheMode::Uncached);
    if (servicesResult.Status() == GattCommunicationStatus::Success) {
        for (auto service : servicesResult.Services()) {
            auto c = co_await FindCharacteristicByDescriptorHandleInServiceAsync(service, descriptor_handle, BluetoothCacheMode::Uncached);
            if (c) co_return c;
        }
    }
    co_return nullptr;
}

winrt::Windows::Foundation::IAsyncOperation<GattCharacteristic> 
FlutterBluePlusWinrtPlugin::GetCharacteristicAsync(
    BluetoothLEDevice device,
    std::string service_uuid_str,
    std::string characteristic_uuid_str,
    std::string primary_service_uuid_str,
    int instance_id)
{
    GattCharacteristic targetChar = nullptr;

    if (!primary_service_uuid_str.empty()) {
        winrt::guid primaryUuid = utils::parse_uuid(primary_service_uuid_str);
        GattDeviceServicesResult primaryResult = co_await device.GetGattServicesForUuidAsync(primaryUuid, BluetoothCacheMode::Cached);
        if (primaryResult.Status() != GattCommunicationStatus::Success || primaryResult.Services().Size() == 0) {
             primaryResult = co_await device.GetGattServicesForUuidAsync(primaryUuid, BluetoothCacheMode::Uncached);
        }

        if (primaryResult.Status() == GattCommunicationStatus::Success) {
            for (auto primaryService : primaryResult.Services()) {
                winrt::guid serviceUuid = utils::parse_uuid(service_uuid_str);
                GattDeviceServicesResult includedResult = co_await primaryService.GetIncludedServicesForUuidAsync(serviceUuid, BluetoothCacheMode::Cached);
                if (includedResult.Status() != GattCommunicationStatus::Success || includedResult.Services().Size() == 0) {
                     includedResult = co_await primaryService.GetIncludedServicesForUuidAsync(serviceUuid, BluetoothCacheMode::Uncached);
                }

                if (includedResult.Status() == GattCommunicationStatus::Success) {
                    for (auto service : includedResult.Services()) {
                        winrt::guid charUuid = utils::parse_uuid(characteristic_uuid_str);
                        GattCharacteristicsResult charsResult = co_await service.GetCharacteristicsForUuidAsync(charUuid, BluetoothCacheMode::Cached);
                        if (charsResult.Status() != GattCommunicationStatus::Success || charsResult.Characteristics().Size() == 0) {
                             charsResult = co_await service.GetCharacteristicsForUuidAsync(charUuid, BluetoothCacheMode::Uncached);
                        }

                        if (charsResult.Status() == GattCommunicationStatus::Success) {
                            for (auto characteristic : charsResult.Characteristics()) {
                                if (instance_id == 0 || static_cast<int32_t>(characteristic.AttributeHandle()) == instance_id) {
                                    targetChar = characteristic; break;
                                }
                            }
                        }
                        if (targetChar) break;
                    }
                }
                if (targetChar) break;
            }
        }
    } else {
        winrt::guid serviceUuid = utils::parse_uuid(service_uuid_str);
        GattDeviceServicesResult servicesResult = co_await device.GetGattServicesForUuidAsync(serviceUuid, BluetoothCacheMode::Cached);
        if (servicesResult.Status() != GattCommunicationStatus::Success || servicesResult.Services().Size() == 0) {
             servicesResult = co_await device.GetGattServicesForUuidAsync(serviceUuid, BluetoothCacheMode::Uncached);
        }

        if (servicesResult.Status() == GattCommunicationStatus::Success) {
                winrt::guid serviceUuid = utils::parse_uuid(service_uuid_str);
                if (service.Uuid() == serviceUuid) {
                     winrt::guid charUuid = utils::parse_uuid(characteristic_uuid_str);
                     auto charsResult = co_await service.GetCharacteristicsForUuidAsync(charUuid, BluetoothCacheMode::Cached);
                     if (charsResult.Status() != GattCommunicationStatus::Success || charsResult.Characteristics().Size() == 0) {
                          charsResult = co_await service.GetCharacteristicsForUuidAsync(charUuid, BluetoothCacheMode::Uncached);
                     }
                     if (charsResult.Status() == GattCommunicationStatus::Success && charsResult.Characteristics().Size() > 0) {
                          targetChar = charsResult.Characteristics().GetAt(0);
                          for (auto c : charsResult.Characteristics()) {
                                if(instance_id != 0 && static_cast<int32_t>(c.AttributeHandle()) == instance_id) {
                                    targetChar = c; break;
                                }
                          }
                     }
                }
                if (targetChar) break;
            }
        }
    }
    co_return targetChar;
}

winrt::Windows::Foundation::IAsyncOperation<GattDescriptor> 
FlutterBluePlusWinrtPlugin::GetDescriptorAsync(
    GattCharacteristic characteristic,
    std::string descriptor_uuid_str)
{
    if (!characteristic) co_return nullptr;

    winrt::guid descUuid = utils::parse_uuid(descriptor_uuid_str);
    GattDescriptor targetDesc = nullptr;

    auto descResult = co_await characteristic.GetDescriptorsForUuidAsync(descUuid, BluetoothCacheMode::Cached);
    if (descResult.Status() == GattCommunicationStatus::Success) {
        for (auto descriptor : descResult.Descriptors()) {
            if (utils::to_uuid_string(descriptor.Uuid()) == descriptor_uuid_str) {
                targetDesc = descriptor; break;
            }
        }
    }

    if (!targetDesc) {
        descResult = co_await characteristic.GetDescriptorsForUuidAsync(descUuid, BluetoothCacheMode::Uncached);
        if (descResult.Status() == GattCommunicationStatus::Success) {
            for (auto descriptor : descResult.Descriptors()) {
                if (utils::to_uuid_string(descriptor.Uuid()) == descriptor_uuid_str) {
                    targetDesc = descriptor; break;
                }
            }
        }
    }
    co_return targetDesc;
}

winrt::Windows::Foundation::IAsyncAction 
FlutterBluePlusWinrtPlugin::PopulateCharacteristicsAsync(
    GattDeviceService service,
    std::string remote_id,
    std::string primaryServiceUuid,
    std::shared_ptr<flutter::EncodableList> outList)
{
    auto charsResult = co_await service.GetCharacteristicsAsync(BluetoothCacheMode::Cached);
    if (charsResult.Status() != GattCommunicationStatus::Success || charsResult.Characteristics().Size() == 0) {
        charsResult = co_await service.GetCharacteristicsAsync(BluetoothCacheMode::Uncached);
    }

    if (charsResult.Status() == GattCommunicationStatus::Success) {
        for (auto characteristic : charsResult.Characteristics()) {
            try {
                flutter::EncodableMap charMap;
                std::string serviceUuid = utils::to_uuid_string(service.Uuid());
                std::string charUuid = utils::to_uuid_string(characteristic.Uuid());
                int32_t handle = static_cast<int32_t>(characteristic.AttributeHandle());

                characteristic_cache_[remote_id + ":" + std::to_string(handle)] = characteristic;

                charMap[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                if (!primaryServiceUuid.empty()) {
                    charMap[flutter::EncodableValue("primary_service_uuid")] = flutter::EncodableValue(primaryServiceUuid);
                }
                charMap[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(serviceUuid);
                charMap[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(charUuid);
                charMap[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(handle);

                auto props = characteristic.CharacteristicProperties();
                flutter::EncodableMap propsMap;
                propsMap[flutter::EncodableValue("broadcast")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Broadcast)) ? 1 : 0);
                propsMap[flutter::EncodableValue("read")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Read)) ? 1 : 0);
                propsMap[flutter::EncodableValue("write_without_response")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::WriteWithoutResponse)) ? 1 : 0);
                propsMap[flutter::EncodableValue("write")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Write)) ? 1 : 0);
                propsMap[flutter::EncodableValue("notify")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Notify)) ? 1 : 0);
                propsMap[flutter::EncodableValue("indicate")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Indicate)) ? 1 : 0);
                propsMap[flutter::EncodableValue("authenticated_signed_writes")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::AuthenticatedSignedWrites)) ? 1 : 0);
                propsMap[flutter::EncodableValue("extended_properties")] = flutter::EncodableValue((static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::ExtendedProperties)) ? 1 : 0);
                propsMap[flutter::EncodableValue("notify_encryption_required")] = flutter::EncodableValue(0);
                propsMap[flutter::EncodableValue("indicate_encryption_required")] = flutter::EncodableValue(0);

                charMap[flutter::EncodableValue("properties")] = propsMap;

                auto descResult = co_await characteristic.GetDescriptorsAsync(BluetoothCacheMode::Cached);
                if (descResult.Status() != GattCommunicationStatus::Success) {
                     descResult = co_await characteristic.GetDescriptorsAsync(BluetoothCacheMode::Uncached);
                }

                flutter::EncodableList descList;
                if (descResult.Status() == GattCommunicationStatus::Success) {
                    for (auto descriptor : descResult.Descriptors()) {
                        try {
                            flutter::EncodableMap descMap;
                            int32_t d_handle = static_cast<int32_t>(descriptor.AttributeHandle());
                            
                            descriptor_cache_[remote_id + ":" + std::to_string(d_handle)] = descriptor;

                            descMap[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                            if (!primaryServiceUuid.empty()) {
                                descMap[flutter::EncodableValue("primary_service_uuid")] = flutter::EncodableValue(primaryServiceUuid);
                            }
                            descMap[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(serviceUuid);
                            descMap[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(charUuid);
                            descMap[flutter::EncodableValue("descriptor_uuid")] = flutter::EncodableValue(utils::to_uuid_string(descriptor.Uuid()));
                            descMap[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(handle);
                            
                            descList.push_back(descMap);
                        } catch(...) {}
                    }
                }
                charMap[flutter::EncodableValue("descriptors")] = descList;
                outList->push_back(charMap);
            } catch(...) {}
        }
    }
    co_return;
}

winrt::Windows::Foundation::IAsyncOperation<GattCharacteristic> 
FlutterBluePlusWinrtPlugin::GetCharacteristicInternalAsync(
    BluetoothLEDevice device,
    std::string remote_id,
    std::string service_uuid_str,
    std::string characteristic_uuid_str,
    std::string primary_service_uuid_str,
    int instance_id)
{
    if (instance_id != 0) {
        std::string cache_key = remote_id + ":" + std::to_string(instance_id);
        auto it = characteristic_cache_.find(cache_key);
        if (it != characteristic_cache_.end()) co_return it->second.as<GattCharacteristic>();
    }

    GattCharacteristic targetChar = nullptr;
    if (instance_id != 0) {
        targetChar = co_await GetCharacteristicByHandleAsync(device, instance_id);
    }
    if (!targetChar) {
        targetChar = co_await GetCharacteristicAsync(device, service_uuid_str, characteristic_uuid_str, primary_service_uuid_str, instance_id);
    }
    
    if (targetChar && instance_id != 0) {
        characteristic_cache_[remote_id + ":" + std::to_string(instance_id)] = targetChar;
    }
    co_return targetChar;
}

// --- Plugin Implementation ---

void FlutterBluePlusWinrtPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
    auto plugin = std::make_unique<FlutterBluePlusWinrtPlugin>(registrar);

    plugin->channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "flutter_blue_plus/methods",
        &flutter::StandardMethodCodec::GetInstance());

    plugin->channel_->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto& call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
}

FlutterBluePlusWinrtPlugin::FlutterBluePlusWinrtPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {
    watcher_.ScanningMode(BluetoothLEScanningMode::Active);
    received_token_ = watcher_.Received(
        { this, &FlutterBluePlusWinrtPlugin::OnAdvertisementReceived });
    stopped_token_ = watcher_.Stopped(
        { this, &FlutterBluePlusWinrtPlugin::OnAdvertisementStopped });
    
    PeriodicConnectionCheck();
}

FlutterBluePlusWinrtPlugin::~FlutterBluePlusWinrtPlugin() {
    is_alive_ = false;
    watcher_.Stopped(stopped_token_);
    watcher_.Received(received_token_);
}

void FlutterBluePlusWinrtPlugin::OnAdvertisementReceived(
    const BluetoothLEAdvertisementWatcher&,
    const BluetoothLEAdvertisementReceivedEventArgs& args) {

    [this, args]() -> winrt::fire_and_forget {
        try {
            co_await ui_thread_;

            if (channel_) {
                std::string remote_id = uint64_to_mac_string(args.BluetoothAddress());
                rssi_cache_[remote_id] = static_cast<int32_t>(args.RawSignalStrengthInDBm());

                if (scan_results_cache_.find(remote_id) == scan_results_cache_.end()) {
                     scan_results_cache_[remote_id] = {};
                }
                auto& map = scan_results_cache_[remote_id];

                map[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                map[flutter::EncodableValue("rssi")] = flutter::EncodableValue(static_cast<int32_t>(args.RawSignalStrengthInDBm()));

                int connectable = args.IsConnectable() ? 1 : 0;
                if (connectable == 0) {
                     auto it = map.find(flutter::EncodableValue("connectable"));
                     if (it != map.end()) {
                         if (auto* val = std::get_if<int>(&it->second)) {
                             if (*val == 1) connectable = 1;
                         }
                     }
                }
                map[flutter::EncodableValue("connectable")] = flutter::EncodableValue(connectable);

                auto advertisement = args.Advertisement();
                std::string localNameStr = utils::to_string(advertisement.LocalName());
                if (!localNameStr.empty()) {
                    map[flutter::EncodableValue("adv_name")] = flutter::EncodableValue(localNameStr);
                    map[flutter::EncodableValue("platform_name")] = flutter::EncodableValue(localNameStr);
                }

                if (args.TransmitPowerLevelInDBm() != nullptr) {
                    map[flutter::EncodableValue("tx_power_level")] =
                        flutter::EncodableValue(static_cast<int32_t>(args.TransmitPowerLevelInDBm().Value()));
                }

                for (const auto& section : advertisement.DataSections()) {
                    if (section.DataType() == 0x19) {
                        auto reader = winrt::Windows::Storage::Streams::DataReader::FromBuffer(section.Data());
                        reader.ByteOrder(winrt::Windows::Storage::Streams::ByteOrder::LittleEndian);
                        uint16_t appearance_value = reader.ReadUInt16();
                        map[flutter::EncodableValue("appearance")] = flutter::EncodableValue(static_cast<int32_t>(appearance_value));
                        break;
                    }
                }

                if (advertisement.ManufacturerData().Size() > 0) {
                    flutter::EncodableMap msd_map;
                    auto it = map.find(flutter::EncodableValue("manufacturer_data"));
                    if (it != map.end()) {
                        if (auto* existing = std::get_if<flutter::EncodableMap>(&it->second)) {
                            msd_map = *existing;
                        }
                    }
                    for (const auto& msd : advertisement.ManufacturerData()) {
                        msd_map[flutter::EncodableValue(static_cast<int64_t>(msd.CompanyId()))] =
                            flutter::EncodableValue(utils::to_vector(msd.Data()));
                    }
                    map[flutter::EncodableValue("manufacturer_data")] = msd_map;
                }

                flutter::EncodableMap service_data_map;
                auto it_sd = map.find(flutter::EncodableValue("service_data"));
                if (it_sd != map.end()) {
                    if (auto* existing = std::get_if<flutter::EncodableMap>(&it_sd->second)) {
                        service_data_map = *existing;
                    }
                }

                bool has_new_service_data = false;
                for (const auto& section : advertisement.GetSectionsByType(0x16)) {
                     auto buffer = section.Data();
                     if (buffer.Length() >= 2) {
                         has_new_service_data = true;
                         auto all_data = utils::to_vector(buffer);
                         uint16_t uuid16 = (all_data[1] << 8) | all_data[0];
                         std::stringstream ss;
                         ss << std::hex << std::setfill('0') << std::setw(4) << uuid16;
                         std::string uuid_str = "0000" + ss.str() + "-0000-1000-8000-00805f9b34fb";
                         std::vector<uint8_t> data_vec(all_data.begin() + 2, all_data.end());
                         service_data_map[flutter::EncodableValue(uuid_str)] = flutter::EncodableValue(data_vec);
                     }
                }
                if (has_new_service_data || !service_data_map.empty()) {
                    map[flutter::EncodableValue("service_data")] = service_data_map;
                }

                if (advertisement.ServiceUuids().Size() > 0) {
                    flutter::EncodableList service_uuids_list;
                    auto it_u = map.find(flutter::EncodableValue("service_uuids"));
                    if (it_u != map.end()) {
                        if (auto* existing = std::get_if<flutter::EncodableList>(&it_u->second)) {
                            service_uuids_list = *existing;
                        }
                    }
                    for (const auto& uuid : advertisement.ServiceUuids()) {
                         std::string uuid_str = utils::to_uuid_string(uuid);
                         bool found = false;
                         for(const auto& existing_val : service_uuids_list) {
                             if (auto* s = std::get_if<std::string>(&existing_val)) {
                                 if (*s == uuid_str) { found = true; break; }
                             }
                         }
                         if (!found) service_uuids_list.push_back(flutter::EncodableValue(uuid_str));
                    }
                    map[flutter::EncodableValue("service_uuids")] = service_uuids_list;
                }

                flutter::EncodableMap response;
                response[flutter::EncodableValue("advertisements")] = flutter::EncodableList{ flutter::EncodableValue(map) };
                channel_->InvokeMethod("OnScanResponse", std::make_unique<flutter::EncodableValue>(response));
            }
        } catch (...) {}
    }();
}

void FlutterBluePlusWinrtPlugin::OnAdvertisementStopped(
    const BluetoothLEAdvertisementWatcher&,
    const BluetoothLEAdvertisementWatcherStoppedEventArgs&) {
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::GetSystemDevicesAsync(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    std::string error_msg;
    try {
        auto selector = BluetoothDevice::GetDeviceSelectorFromPairingState(true);
        DeviceInformationCollection deviceInfoCollection = co_await DeviceInformation::FindAllAsync(selector);
        flutter::EncodableMap response = {};
        flutter::EncodableList deviceList;

        for (auto&& deviceInfo : deviceInfoCollection) {
            try {
                auto bleDevice = co_await BluetoothLEDevice::FromIdAsync(deviceInfo.Id());
                if (!bleDevice) continue;
                std::string remote_id = uint64_to_mac_string(bleDevice.BluetoothAddress());
                bool is_connected = (bleDevice.ConnectionStatus() == BluetoothConnectionStatus::Connected);
                flutter::EncodableMap deviceMap = {};
                deviceMap[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                deviceMap[flutter::EncodableValue("platform_name")] = flutter::EncodableValue(utils::to_string(deviceInfo.Name()));
                deviceMap[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(is_connected ? 1 : 0);
                deviceList.push_back(flutter::EncodableValue(deviceMap));
            } catch (...) {}
        }
        response[flutter::EncodableValue("devices")] = deviceList;
        co_await ui_thread_;
        result->Success(flutter::EncodableValue(response));
        co_return;
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error occurred"; }

    if (!error_msg.empty()) {
        co_await ui_thread_;
        result->Error("getSystemDevices", error_msg);
    }
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::GetAdapterStateAsync(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    std::string error_msg;
    try {
        auto radios = co_await Radio::GetRadiosAsync();
        std::string adapter_name = "";
        int adapter_state = 0;
        for (auto radio : radios) {
            if (radio.Kind() != RadioKind::Bluetooth) continue;
            adapter_name = utils::to_string(radio.Name());
            switch (radio.State()) {
            case RadioState::On: adapter_state = 4; break;
            case RadioState::Off: adapter_state = 6; break;
            default: adapter_state = 0; break;
            }
            break;
        }
        flutter::EncodableMap response = {};
        response[flutter::EncodableValue("adapter_state")] = flutter::EncodableValue(adapter_state);
        response[flutter::EncodableValue("adapter_name")] = flutter::EncodableValue(adapter_name);

        co_await ui_thread_;
        result->Success(flutter::EncodableValue(response));
        co_return;
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error occurred"; }

    if (!error_msg.empty()) {
        co_await ui_thread_;
        result->Error("getAdapterState", error_msg);
    }
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::ConnectAsync(
    std::string remote_id,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    std::string error_msg;
    try {
        uint64_t bluetoothAddress = utils::mac_to_uint64(remote_id);
        
        co_await ui_thread_;
        auto it_existing = std::find_if(connected_devices_.begin(), connected_devices_.end(),
                [&](const auto& pair) { return pair.first == remote_id; });
        if (it_existing != connected_devices_.end()) {
             flutter::EncodableMap connection_state;
             connection_state[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
             connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(1);
             channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));
             result->Success(flutter::EncodableValue(true));
             co_return;
        }

        co_await winrt::resume_background();
        auto device = co_await BluetoothLEDevice::FromBluetoothAddressAsync(bluetoothAddress);
        if (device) {
            co_await ui_thread_;
            auto it = std::find_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
                [&](const auto& pair) { return pair.first == remote_id; });
            if (it == currently_connecting_devices_.end()) {
                 currently_connecting_devices_.emplace_back(remote_id, device);
            }
            device.ConnectionStatusChanged({ this, &FlutterBluePlusWinrtPlugin::OnConnectionStatusChanged });

            co_await winrt::resume_background();
            // Force connection by discovery
            auto gatt_result = co_await device.GetGattServicesAsync(BluetoothCacheMode::Uncached);
            
            // Strictly wait for ConnectionStatus to be Connected (up to 5s)
            int wait_retry = 0;
            while (device.ConnectionStatus() != BluetoothConnectionStatus::Connected && wait_retry < 10) {
                 co_await winrt::resume_after(std::chrono::milliseconds(500));
                 wait_retry++;
            }

            co_await ui_thread_;
            
            auto it_connecting = std::find_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
               [&](const auto& pair) { return pair.first == remote_id; });
            
            if (it_connecting == currently_connecting_devices_.end()) {
                if (device) device.Close();
                result->Success(flutter::EncodableValue(false));
                co_return;
            }

            if (gatt_result.Status() == GattCommunicationStatus::Success && device.ConnectionStatus() == BluetoothConnectionStatus::Connected) {
                 auto it_connected = std::find_if(connected_devices_.begin(), connected_devices_.end(),
                    [&](const auto& pair) { return pair.first == remote_id; });
                 if (it_connected == connected_devices_.end()) connected_devices_.emplace_back(remote_id, device);
                 
                 currently_connecting_devices_.erase(std::remove_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
                    [&](const auto& pair) { return pair.first == remote_id; }), currently_connecting_devices_.end());

                 flutter::EncodableMap connection_state;
                 connection_state[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                 connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(1);
                 channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));
                 result->Success(flutter::EncodableValue(true));
                 co_return;
            } else {
                 std::vector<BluetoothLEDevice> devices_to_close;
                 for (auto& p : connected_devices_) { if (p.first == remote_id) devices_to_close.push_back(p.second.as<BluetoothLEDevice>()); }
                 for (auto& p : currently_connecting_devices_) { if (p.first == remote_id) devices_to_close.push_back(p.second.as<BluetoothLEDevice>()); }

                 connected_devices_.erase(std::remove_if(connected_devices_.begin(), connected_devices_.end(),
                    [&](const auto& pair) { return pair.first == remote_id; }), connected_devices_.end());

                 currently_connecting_devices_.erase(std::remove_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
                    [&](const auto& pair) { return pair.first == remote_id; }), currently_connecting_devices_.end());
                 
                 for (auto& d : devices_to_close) { try { d.Close(); } catch(...) {} }

                 flutter::EncodableMap connection_state;
                 connection_state[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                 connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(0);
                 channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));

                 result->Success(flutter::EncodableValue(false));
                 co_return;
            }
        } else error_msg = "Device not found.";
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error occurred"; }

    if (!error_msg.empty()) {
        co_await ui_thread_;
        result->Success(flutter::EncodableValue(false));
    }
}

std::string FlutterBluePlusWinrtPlugin::uint64_to_mac_string(uint64_t addr) {
    std::stringstream stream;
    stream << std::hex << std::uppercase << std::setfill('0') << std::setw(2) << ((addr >> 40) & 0xFF) << ":" << std::setw(2) << ((addr >> 32) & 0xFF) << ":" << std::setw(2) << ((addr >> 24) & 0xFF) << ":" << std::setw(2) << ((addr >> 16) & 0xFF) << ":" << std::setw(2) << ((addr >> 8) & 0xFF) << ":" << std::setw(2) << (addr & 0xFF);
    return stream.str();
}

void FlutterBluePlusWinrtPlugin::OnConnectionStatusChanged(const BluetoothLEDevice& device, const IInspectable&) {
    [&](BluetoothLEDevice d) -> winrt::fire_and_forget {
        co_await ui_thread_;
        std::string remote_id = uint64_to_mac_string(d.BluetoothAddress());
        flutter::EncodableMap connection_state;
        connection_state[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);

        if (d.ConnectionStatus() == BluetoothConnectionStatus::Connected) {
             bool solicited = false;
             auto it_connected = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
             if (it_connected != connected_devices_.end()) {
                  solicited = true;
             } else {
                  auto it_connecting = std::find_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
                  if(it_connecting != currently_connecting_devices_.end()) {
                       auto dev_obj = it_connecting->second;
                       connected_devices_.emplace_back(remote_id, dev_obj);
                       currently_connecting_devices_.erase(std::remove_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
                           [&](const auto& pair) { return pair.first == remote_id; }), currently_connecting_devices_.end());
                       solicited = true;
                  }
             }

             if (solicited) {
                connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(1);
                channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));
             } else {
                Log("Unsolicited connection for %s, closing to prevent unintended auto-reconnect.", remote_id.c_str());
                try { d.Close(); } catch(...) {}
             }
        } else {
            ClearDeviceResources(remote_id);

            std::vector<BluetoothLEDevice> devices_to_close;
            for (auto& p : connected_devices_) { if (p.first == remote_id) devices_to_close.push_back(p.second.as<BluetoothLEDevice>()); }
            for (auto& p : currently_connecting_devices_) { if (p.first == remote_id) devices_to_close.push_back(p.second.as<BluetoothLEDevice>()); }

            currently_connecting_devices_.erase(std::remove_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
                [&](const auto& pair) { return pair.first == remote_id; }), currently_connecting_devices_.end());

            connected_devices_.erase(std::remove_if(connected_devices_.begin(), connected_devices_.end(),
                [&](const auto& pair) { return pair.first == remote_id; }), connected_devices_.end());
            
            for (auto& d_close : devices_to_close) { try { d_close.Close(); } catch(...) {} }

            connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(0);
            channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));
        }
    }(device);
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::DiscoverServicesAsync(
    std::string remote_id,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    auto result_ptr = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    std::string error_msg;
    try {
        BluetoothLEDevice device = nullptr;
        { auto it = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
          if (it != connected_devices_.end()) device = it->second.as<BluetoothLEDevice>(); }
        if (!device) { error_msg = "device is disconnected"; }
        else {
            co_await winrt::resume_background();
            auto servicesResult = co_await device.GetGattServicesAsync(BluetoothCacheMode::Uncached);
            if (servicesResult.Status() != GattCommunicationStatus::Success) {
                 error_msg = "GetGattServicesAsync failed";
            } else {
                flutter::EncodableList servicesList;
                for (auto service : servicesResult.Services()) {
                     service_cache_[remote_id].push_back(service);
                     flutter::EncodableMap serviceMap;
                     std::string serviceUuid = utils::to_uuid_string(service.Uuid());
                     serviceMap[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                     serviceMap[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(serviceUuid);
                     auto charsList = std::make_shared<flutter::EncodableList>();
                     co_await PopulateCharacteristicsAsync(service, remote_id, "", charsList);
                     serviceMap[flutter::EncodableValue("characteristics")] = *charsList;
                     servicesList.push_back(serviceMap);

                     auto includedResult = co_await service.GetIncludedServicesAsync(BluetoothCacheMode::Cached);
                     if (includedResult.Status() == GattCommunicationStatus::Success) {
                         for (auto includedService : includedResult.Services()) {
                             service_cache_[remote_id].push_back(includedService);
                             flutter::EncodableMap includedMap;
                             std::string includedUuid = utils::to_uuid_string(includedService.Uuid());
                             includedMap[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                             includedMap[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(includedUuid);
                             includedMap[flutter::EncodableValue("primary_service_uuid")] = flutter::EncodableValue(serviceUuid);
                             auto includedCharsList = std::make_shared<flutter::EncodableList>();
                             co_await PopulateCharacteristicsAsync(includedService, remote_id, serviceUuid, includedCharsList);
                             includedMap[flutter::EncodableValue("characteristics")] = *includedCharsList;
                             servicesList.push_back(includedMap);
                         }
                     }
                }
                flutter::EncodableMap response;
                response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                response[flutter::EncodableValue("services")] = servicesList;
                response[flutter::EncodableValue("success")] = flutter::EncodableValue(1);
                response[flutter::EncodableValue("error_code")] = flutter::EncodableValue(0);
                response[flutter::EncodableValue("error_string")] = flutter::EncodableValue("GATT_SUCCESS");
                co_await ui_thread_;
                channel_->InvokeMethod("OnDiscoveredServices", std::make_unique<flutter::EncodableValue>(response));
                result_ptr->Success(flutter::EncodableValue(true));
                co_return;
            }
        }
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error"; }
    
    if (error_msg.empty()) error_msg = "Unknown error";
    co_await ui_thread_;
    result_ptr->Error("discoverServices", error_msg);
}

void FlutterBluePlusWinrtPlugin::OnCharacteristicValueChanged(std::string remote_id, const GattCharacteristic& sender, const GattValueChangedEventArgs& args) {
    [this, remote_id, sender, args]() -> winrt::fire_and_forget {
        try {
            co_await ui_thread_;
            flutter::EncodableMap response;
            response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
            response[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(utils::to_uuid_string(sender.Service().Uuid()));
            response[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(utils::to_uuid_string(sender.Uuid()));
            response[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(static_cast<int32_t>(sender.AttributeHandle()));
            response[flutter::EncodableValue("value")] = flutter::EncodableValue(utils::to_vector(args.CharacteristicValue()));
            response[flutter::EncodableValue("success")] = flutter::EncodableValue(1);
            response[flutter::EncodableValue("error_code")] = flutter::EncodableValue(0);
            response[flutter::EncodableValue("error_string")] = flutter::EncodableValue("GATT_SUCCESS");
            channel_->InvokeMethod("OnCharacteristicReceived", std::make_unique<flutter::EncodableValue>(response));
        } catch(...) {}
    }();
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::SetNotifyValueAsync(std::shared_ptr<flutter::EncodableMap> args_ptr) {
    co_await winrt::resume_background();
    flutter::EncodableMap& args = *args_ptr;
    std::string remote_id = utils::from_value<std::string>(&args[flutter::EncodableValue("remote_id")]);
    std::string service_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("service_uuid")]);
    std::string characteristic_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("characteristic_uuid")]);
    std::string primary_service_uuid_str = "";
    auto it_primary = args.find(flutter::EncodableValue("primary_service_uuid"));
    if (it_primary != args.end()) primary_service_uuid_str = utils::from_value<std::string>(&it_primary->second);
    int instance_id = utils::from_value<int>(&args[flutter::EncodableValue("instance_id")]);
    bool enable = utils::from_value<bool>(&args[flutter::EncodableValue("enable")]);
    bool force_indications = false;
    auto it_force = args.find(flutter::EncodableValue("force_indications"));
    if (it_force != args.end()) force_indications = utils::from_value<bool>(&it_force->second);

    std::string error_string = "Unknown Error";
    bool success_event = false;
    std::vector<uint8_t> return_value = {0x00, 0x00};
    GattCharacteristic targetChar = nullptr;
    std::string actual_service_uuid = service_uuid_hint;
    std::string actual_char_uuid = characteristic_uuid_hint;

    try {
        BluetoothLEDevice device = nullptr;
        co_await ui_thread_;
        { auto it = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
          if (it != connected_devices_.end()) device = it->second.as<BluetoothLEDevice>(); }
        co_await winrt::resume_background();
        if (!device) { error_string = "Device not connected"; }
        else {
            targetChar = co_await this->GetCharacteristicInternalAsync(device, remote_id, service_uuid_hint, characteristic_uuid_hint, primary_service_uuid_str, instance_id);
            if (!targetChar) { error_string = "Characteristic not found"; }
            else {
                actual_service_uuid = utils::to_uuid_string(targetChar.Service().Uuid());
                actual_char_uuid = utils::to_uuid_string(targetChar.Uuid());
                std::string token_key = remote_id + ":" + actual_service_uuid + ":" + actual_char_uuid + ":" + std::to_string(instance_id);

                if (enable) {
                    GattClientCharacteristicConfigurationDescriptorValue cccdValue = GattClientCharacteristicConfigurationDescriptorValue::None;
                    auto props = targetChar.CharacteristicProperties();
                    bool canNotify = (static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Notify)) != 0;
                    bool canIndicate = (static_cast<uint32_t>(props) & static_cast<uint32_t>(GattCharacteristicProperties::Indicate)) != 0;
                    if (force_indications && canIndicate) { cccdValue = GattClientCharacteristicConfigurationDescriptorValue::Indicate; return_value = {0x02, 0x00}; }
                    else if (canNotify) { cccdValue = GattClientCharacteristicConfigurationDescriptorValue::Notify; return_value = {0x01, 0x00}; }
                    else if (canIndicate) { cccdValue = GattClientCharacteristicConfigurationDescriptorValue::Indicate; return_value = {0x02, 0x00}; }
                    else { error_string = "Notify/Indicate not supported"; goto send_event; }

                    GattCommunicationStatus status = GattCommunicationStatus::ProtocolError;
                    try { status = co_await targetChar.WriteClientCharacteristicConfigurationDescriptorAsync(cccdValue); } catch (...) {}
                    if (status != GattCommunicationStatus::Success) {
                        GattDescriptor cccdDescriptor = co_await GetDescriptorAsync(targetChar, "2902");
                        if (cccdDescriptor) {
                            auto writer = winrt::Windows::Storage::Streams::DataWriter();
                            writer.ByteOrder(winrt::Windows::Storage::Streams::ByteOrder::LittleEndian);
                            writer.WriteUInt16((cccdValue == GattClientCharacteristicConfigurationDescriptorValue::Indicate) ? 2 : 1);
                            auto writeResult = co_await cccdDescriptor.WriteValueWithResultAsync(writer.DetachBuffer());
                            status = writeResult.Status();
                        }
                    }

                    if (status != GattCommunicationStatus::Success && (actual_char_uuid == "2a05" || actual_char_uuid == "2A05")) {
                        status = GattCommunicationStatus::Success;
                    }

                    if (status == GattCommunicationStatus::Success) {
                        co_await ui_thread_;
                        auto it = subscribed_characteristics_.find(token_key);
                        if (it != subscribed_characteristics_.end()) {
                            try { it->second.characteristic.as<GattCharacteristic>().ValueChanged(it->second.token); } catch(...) {}
                            subscribed_characteristics_.erase(it);
                        }
                        auto token = targetChar.ValueChanged([this, remote_id](GattCharacteristic const& sender, GattValueChangedEventArgs const& args) {
                            this->OnCharacteristicValueChanged(remote_id, sender, args);
                        });
                        subscribed_characteristics_[token_key] = { targetChar, token };
                        success_event = true; error_string = "GATT_SUCCESS";
                    } else error_string = "Write CCCD failed: " + std::to_string((int)status);
                } else {
                    return_value = {0x00, 0x00};
                    GattCommunicationStatus status = co_await targetChar.WriteClientCharacteristicConfigurationDescriptorAsync(GattClientCharacteristicConfigurationDescriptorValue::None);
                    if (status == GattCommunicationStatus::Success || actual_char_uuid == "2a05") {
                        co_await ui_thread_;
                        auto it = subscribed_characteristics_.find(token_key);
                        if (it != subscribed_characteristics_.end()) {
                            try { it->second.characteristic.as<GattCharacteristic>().ValueChanged(it->second.token); } catch(...) {}
                            subscribed_characteristics_.erase(it);
                        }
                        success_event = true; error_string = "GATT_SUCCESS";
                    } else error_string = "Disable CCCD failed";
                }
            }
        }
    } catch (const std::exception& ex) { error_string = ex.what(); }
      catch (...) { error_string = "Unknown Exception"; }

send_event:
    co_await ui_thread_;
    flutter::EncodableMap response;
    response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
    response[flutter::EncodableValue("primary_service_uuid")] = primary_service_uuid_str.empty() ? flutter::EncodableValue() : flutter::EncodableValue(primary_service_uuid_str);
    response[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(actual_service_uuid);
    response[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(actual_char_uuid);
    response[flutter::EncodableValue("descriptor_uuid")] = flutter::EncodableValue("2902");
    response[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(instance_id);
    response[flutter::EncodableValue("value")] = flutter::EncodableValue(return_value);
    response[flutter::EncodableValue("success")] = flutter::EncodableValue(success_event ? 1 : 0);
    response[flutter::EncodableValue("error_code")] = flutter::EncodableValue(success_event ? 0 : 1);
    response[flutter::EncodableValue("error_string")] = flutter::EncodableValue(error_string);
    if (channel_) channel_->InvokeMethod("OnDescriptorWritten", std::make_unique<flutter::EncodableValue>(response));
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::ReadCharacteristicAsync(flutter::EncodableMap args, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto result_ptr = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    std::string error_msg;
    try {
        std::string remote_id = utils::from_value<std::string>(&args[flutter::EncodableValue("remote_id")]);
        std::string service_uuid_str = utils::from_value<std::string>(&args[flutter::EncodableValue("service_uuid")]);
        std::string characteristic_uuid_str = utils::from_value<std::string>(&args[flutter::EncodableValue("characteristic_uuid")]);
        int instance_id = utils::from_value<int>(&args[flutter::EncodableValue("instance_id")]);
        std::string primary_service_uuid_str = "";
        auto it_primary = args.find(flutter::EncodableValue("primary_service_uuid"));
        if (it_primary != args.end()) primary_service_uuid_str = utils::from_value<std::string>(&it_primary->second);

        BluetoothLEDevice device = nullptr;
        { auto it = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
          if (it != connected_devices_.end()) device = it->second.as<BluetoothLEDevice>(); }
        if (!device) { error_msg = "device is disconnected"; }
        else {
            co_await winrt::resume_background();
            GattCharacteristic targetChar = co_await this->GetCharacteristicInternalAsync(device, remote_id, service_uuid_str, characteristic_uuid_str, primary_service_uuid_str, instance_id);
            if (!targetChar) { error_msg = "Characteristic not found"; }
            else {
                auto readResult = co_await targetChar.ReadValueAsync(BluetoothCacheMode::Uncached);
                if (readResult.Status() == GattCommunicationStatus::Success) {
                    flutter::EncodableMap response;
                    response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                    response[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(service_uuid_str);
                    response[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(characteristic_uuid_str);
                    response[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(instance_id);
                    response[flutter::EncodableValue("value")] = flutter::EncodableValue(utils::to_vector(readResult.Value()));
                    response[flutter::EncodableValue("success")] = flutter::EncodableValue(1);
                    response[flutter::EncodableValue("error_code")] = flutter::EncodableValue(0);
                    response[flutter::EncodableValue("error_string")] = flutter::EncodableValue("GATT_SUCCESS");
                    co_await ui_thread_;
                    channel_->InvokeMethod("OnCharacteristicReceived", std::make_unique<flutter::EncodableValue>(response));
                    result_ptr->Success(flutter::EncodableValue(true));
                    co_return;
                } else { error_msg = "Read failed: " + std::to_string((int)readResult.Status()); }
            }
        }
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error"; }

    co_await ui_thread_;
    result_ptr->Error("readCharacteristic", error_msg);
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::WriteCharacteristicAsync(flutter::EncodableMap args, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto result_ptr = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    std::string error_msg;
    try {
        std::string remote_id = utils::from_value<std::string>(&args[flutter::EncodableValue("remote_id")]);
        std::string service_uuid_str = utils::from_value<std::string>(&args[flutter::EncodableValue("service_uuid")]);
        std::string characteristic_uuid_str = utils::from_value<std::string>(&args[flutter::EncodableValue("characteristic_uuid")]);
        int instance_id = utils::from_value<int>(&args[flutter::EncodableValue("instance_id")]);
        std::vector<uint8_t> value = utils::from_value<std::vector<uint8_t>>(&args[flutter::EncodableValue("value")]);
        int write_type = utils::from_value<int>(&args[flutter::EncodableValue("write_type")]);
        std::string primary_service_uuid_str = "";
        auto it_primary = args.find(flutter::EncodableValue("primary_service_uuid"));
        if (it_primary != args.end()) primary_service_uuid_str = utils::from_value<std::string>(&it_primary->second);

        BluetoothLEDevice device = nullptr;
        { auto it = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
          if (it != connected_devices_.end()) device = it->second.as<BluetoothLEDevice>(); }
        if (!device) { error_msg = "device is disconnected"; }
        else {
            co_await winrt::resume_background();
            GattCharacteristic targetChar = co_await this->GetCharacteristicInternalAsync(device, remote_id, service_uuid_str, characteristic_uuid_str, primary_service_uuid_str, instance_id);
            if (!targetChar) { error_msg = "Characteristic not found"; }
            else {
                auto writer = winrt::Windows::Storage::Streams::DataWriter();
                writer.WriteBytes(value);
                GattWriteOption option = (write_type == 1) ? GattWriteOption::WriteWithoutResponse : GattWriteOption::WriteWithResponse;
                auto writeResult = co_await targetChar.WriteValueWithResultAsync(writer.DetachBuffer(), option);

                co_await ui_thread_;
                flutter::EncodableMap response;
                response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                response[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(service_uuid_str);
                response[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(characteristic_uuid_str);
                response[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(instance_id);
                response[flutter::EncodableValue("value")] = flutter::EncodableValue(value);
                response[flutter::EncodableValue("success")] = flutter::EncodableValue(writeResult.Status() == GattCommunicationStatus::Success ? 1 : 0);
                response[flutter::EncodableValue("error_code")] = flutter::EncodableValue((int)writeResult.Status());
                response[flutter::EncodableValue("error_string")] = flutter::EncodableValue(writeResult.Status() == GattCommunicationStatus::Success ? "GATT_SUCCESS" : "Write failed");
                channel_->InvokeMethod("OnCharacteristicWritten", std::make_unique<flutter::EncodableValue>(response));
                result_ptr->Success(flutter::EncodableValue(true));
                co_return;
            }
        }
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error"; }

    co_await ui_thread_;
    result_ptr->Error("writeCharacteristic", error_msg);
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::ReadDescriptorAsync(flutter::EncodableMap args, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto result_ptr = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    std::string error_msg;
    try {
        std::string remote_id = utils::from_value<std::string>(&args[flutter::EncodableValue("remote_id")]);
        std::string service_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("service_uuid")]);
        std::string characteristic_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("characteristic_uuid")]);
        std::string descriptor_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("descriptor_uuid")]);
        int instance_id = utils::from_value<int>(&args[flutter::EncodableValue("instance_id")]);
        std::string primary_service_uuid_str = "";
        auto it_primary = args.find(flutter::EncodableValue("primary_service_uuid"));
        if (it_primary != args.end()) primary_service_uuid_str = utils::from_value<std::string>(&it_primary->second);

        BluetoothLEDevice device = nullptr;
        { auto it = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
          if (it != connected_devices_.end()) device = it->second.as<BluetoothLEDevice>(); }
        if (!device) { error_msg = "device is disconnected"; }
        else {
            co_await winrt::resume_background();

            GattDescriptor targetDesc = nullptr;
            if (instance_id != 0) {
                std::string d_key = remote_id + ":" + std::to_string(instance_id);
                auto it_d = descriptor_cache_.find(d_key);
                if (it_d != descriptor_cache_.end()) targetDesc = it_d->second.as<GattDescriptor>();
            }

            if (!targetDesc) {
                GattCharacteristic targetChar = co_await this->GetCharacteristicByDescriptorHandleAsync(device, instance_id);
                if (!targetChar) {
                    targetChar = co_await this->GetCharacteristicInternalAsync(device, remote_id, service_uuid_hint, characteristic_uuid_hint, primary_service_uuid_str, instance_id);
                }

                if (targetChar) {
                    targetDesc = co_await GetDescriptorAsync(targetChar, descriptor_uuid_hint);
                }
            }

            if (!targetDesc) { error_msg = "Descriptor not found"; }
            else {
                auto readResult = co_await targetDesc.ReadValueAsync(BluetoothCacheMode::Uncached);
                if (readResult.Status() == GattCommunicationStatus::Success) {
                    flutter::EncodableMap response;
                    response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                    response[flutter::EncodableValue("primary_service_uuid")] = primary_service_uuid_str.empty() ? flutter::EncodableValue() : flutter::EncodableValue(primary_service_uuid_str);
                    response[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(service_uuid_hint);
                    response[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(characteristic_uuid_hint);
                    response[flutter::EncodableValue("descriptor_uuid")] = flutter::EncodableValue(utils::to_uuid_string(targetDesc.Uuid()));
                    response[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(instance_id);
                    response[flutter::EncodableValue("value")] = flutter::EncodableValue(utils::to_vector(readResult.Value()));
                    response[flutter::EncodableValue("success")] = flutter::EncodableValue(1);
                    response[flutter::EncodableValue("error_code")] = flutter::EncodableValue(0);
                    response[flutter::EncodableValue("error_string")] = flutter::EncodableValue("GATT_SUCCESS");
                    
                    co_await ui_thread_;
                    channel_->InvokeMethod("OnDescriptorRead", std::make_unique<flutter::EncodableValue>(response));
                    result_ptr->Success(flutter::EncodableValue(true));
                    co_return;
                } else { error_msg = "Read failed: " + std::to_string((int)readResult.Status()); }
            }
        }
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error"; }

    co_await ui_thread_;
    result_ptr->Error("readDescriptor", error_msg);
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::WriteDescriptorAsync(flutter::EncodableMap args, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto result_ptr = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    std::string error_msg;
    try {
        std::string remote_id = utils::from_value<std::string>(&args[flutter::EncodableValue("remote_id")]);
        std::string service_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("service_uuid")]);
        std::string characteristic_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("characteristic_uuid")]);
        std::string descriptor_uuid_hint = utils::from_value<std::string>(&args[flutter::EncodableValue("descriptor_uuid")]);
        std::vector<uint8_t> value = utils::from_value<std::vector<uint8_t>>(&args[flutter::EncodableValue("value")]);
        int instance_id = utils::from_value<int>(&args[flutter::EncodableValue("instance_id")]);
        std::string primary_service_uuid_str = "";
        auto it_primary = args.find(flutter::EncodableValue("primary_service_uuid"));
        if (it_primary != args.end()) primary_service_uuid_str = utils::from_value<std::string>(&it_primary->second);

        BluetoothLEDevice device = nullptr;
        { auto it = std::find_if(connected_devices_.begin(), connected_devices_.end(), [&](const auto& pair) { return pair.first == remote_id; });
          if (it != connected_devices_.end()) device = it->second.as<BluetoothLEDevice>(); }
        if (!device) { error_msg = "device is disconnected"; }
        else {
            co_await winrt::resume_background();
            
            GattDescriptor targetDesc = nullptr;
            if (instance_id != 0) {
                std::string d_key = remote_id + ":" + std::to_string(instance_id);
                auto it_d = descriptor_cache_.find(d_key);
                if (it_d != descriptor_cache_.end()) targetDesc = it_d->second.as<GattDescriptor>();
            }

            if (!targetDesc) {
                GattCharacteristic targetChar = co_await this->GetCharacteristicInternalAsync(device, remote_id, service_uuid_hint, characteristic_uuid_hint, primary_service_uuid_str, instance_id);
                if (targetChar) {
                    targetDesc = co_await GetDescriptorAsync(targetChar, descriptor_uuid_hint);
                }
            }

            if (!targetDesc) { error_msg = "Descriptor not found"; }
            else {
                auto writer = winrt::Windows::Storage::Streams::DataWriter();
                writer.WriteBytes(value);
                auto writeResult = co_await targetDesc.WriteValueWithResultAsync(writer.DetachBuffer());
                if (writeResult.Status() == GattCommunicationStatus::Success) {
                    flutter::EncodableMap response;
                    response[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                    response[flutter::EncodableValue("primary_service_uuid")] = primary_service_uuid_str.empty() ? flutter::EncodableValue() : flutter::EncodableValue(primary_service_uuid_str);
                    response[flutter::EncodableValue("service_uuid")] = flutter::EncodableValue(service_uuid_hint);
                    response[flutter::EncodableValue("characteristic_uuid")] = flutter::EncodableValue(characteristic_uuid_hint);
                    response[flutter::EncodableValue("descriptor_uuid")] = flutter::EncodableValue(utils::to_uuid_string(targetDesc.Uuid()));
                    response[flutter::EncodableValue("instance_id")] = flutter::EncodableValue(instance_id);
                    response[flutter::EncodableValue("value")] = flutter::EncodableValue(value);
                    response[flutter::EncodableValue("success")] = flutter::EncodableValue(1);
                    response[flutter::EncodableValue("error_code")] = flutter::EncodableValue(0);
                    response[flutter::EncodableValue("error_string")] = flutter::EncodableValue("GATT_SUCCESS");
                    
                    co_await ui_thread_;
                    channel_->InvokeMethod("OnDescriptorWritten", std::make_unique<flutter::EncodableValue>(response));
                    result_ptr->Success(flutter::EncodableValue(true));
                    co_return;
                } else { error_msg = "Write failed: " + std::to_string((int)writeResult.Status()); }
            }
        }
    } catch (const std::exception& e) { error_msg = e.what(); }
      catch (...) { error_msg = "Unknown error"; }

    co_await ui_thread_;
    result_ptr->Error("writeDescriptor", error_msg);
}

void FlutterBluePlusWinrtPlugin::ClearDeviceResources(std::string remote_id) {
    for (auto it = subscribed_characteristics_.begin(); it != subscribed_characteristics_.end(); ) {
        if (it->first.find(remote_id) == 0) {
            try {
                auto characteristic = it->second.characteristic.as<GattCharacteristic>();
                if (characteristic) characteristic.ValueChanged(it->second.token);
            } catch (...) {}
            it = subscribed_characteristics_.erase(it);
        } else {
            ++it;
        }
    }

    for (auto it = characteristic_cache_.begin(); it != characteristic_cache_.end(); ) {
        if (it->first.find(remote_id) == 0) it = characteristic_cache_.erase(it);
        else ++it;
    }
    for (auto it = descriptor_cache_.begin(); it != descriptor_cache_.end(); ) {
        if (it->first.find(remote_id) == 0) it = descriptor_cache_.erase(it);
        else ++it;
    }

    auto it_s = service_cache_.find(remote_id);
    if (it_s != service_cache_.end()) {
        for (auto& inspectable : it_s->second) {
            try {
                auto service = inspectable.as<GattDeviceService>();
                if (service) service.Close();
            } catch (...) {}
        }
        service_cache_.erase(it_s);
    }
}

winrt::fire_and_forget FlutterBluePlusWinrtPlugin::PeriodicConnectionCheck() {
    while (is_alive_) {
        co_await winrt::resume_after(winrt::Windows::Foundation::TimeSpan(20000000));
        if (!is_alive_) co_return;
        co_await ui_thread_;
        if (!is_alive_) co_return;

        std::vector<std::string> mac_to_remove;
        for (const auto& pair : connected_devices_) {
            std::string remote_id = pair.first;
            auto device = pair.second.as<BluetoothLEDevice>();
            bool is_connected = false;
            try { if (device) is_connected = (device.ConnectionStatus() == BluetoothConnectionStatus::Connected); } catch (...) {}
            if (!is_connected) {
                Log("PeriodicCheck: Device %s disconnected, marking for removal.", remote_id.c_str());
                mac_to_remove.push_back(remote_id);
            }
        }

        for (const auto& remote_id : mac_to_remove) {
            ClearDeviceResources(remote_id);
            if (channel_) {
                flutter::EncodableMap connection_state;
                connection_state[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
                connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(0); 
                channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));
            }
            
            std::vector<BluetoothLEDevice> to_close;
            connected_devices_.erase(std::remove_if(connected_devices_.begin(), connected_devices_.end(),
                [&](const auto& pair) {
                    if (pair.first == remote_id) {
                        try { auto d = pair.second.as<BluetoothLEDevice>(); if (d) to_close.push_back(d); } catch(...) {}
                        return true;
                    }
                    return false;
                }), connected_devices_.end());
            
            for (auto& d : to_close) { try { d.Close(); } catch(...) {} }
        }
    }
}

void FlutterBluePlusWinrtPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    const auto& method = method_call.method_name();
    if (method == "flutterRestart") {
        int count = static_cast<int>(connected_devices_.size());
        watcher_.Stop();

        std::vector<BluetoothLEDevice> to_close;
        for (const auto& pair : connected_devices_) { 
            try { if (auto device = pair.second.as<BluetoothLEDevice>()) to_close.push_back(device); } catch(...) {}
            ClearDeviceResources(pair.first);
        }
        for (const auto& pair : currently_connecting_devices_) {
            try { if (auto device = pair.second.as<BluetoothLEDevice>()) to_close.push_back(device); } catch(...) {}
        }
        connected_devices_.clear(); 
        currently_connecting_devices_.clear(); 
        rssi_cache_.clear(); 
        scan_results_cache_.clear(); 
        subscribed_characteristics_.clear(); 
        characteristic_cache_.clear(); 
        descriptor_cache_.clear(); 
        service_cache_.clear();

        for (auto& d : to_close) { try { d.Close(); } catch(...) {} }

        result->Success(flutter::EncodableValue(count)); return;
    }
    if (method == "startScan") { scan_results_cache_.clear(); watcher_.Start(); result->Success(flutter::EncodableValue(true)); return; }
    if (method == "stopScan") { watcher_.Stop(); result->Success(flutter::EncodableValue(true)); return; }
    if (method == "getSystemDevices") { GetSystemDevicesAsync(std::move(result)); return; }
    if (method == "getAdapterState") { GetAdapterStateAsync(std::move(result)); return; }
    if (method == "connect") {
        const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        std::string remote_id = ""; if (args) { auto it = args->find(flutter::EncodableValue("remote_id")); if (it != args->end()) remote_id = utils::from_value<std::string>(&it->second); }
        ConnectAsync(remote_id, std::move(result)); return;
    }
    if (method == "disconnect") {
        const auto* remote_id_val_ptr = std::get_if<std::string>(method_call.arguments());
        if (remote_id_val_ptr) {
            std::string remote_id = *remote_id_val_ptr;
            
            std::vector<BluetoothLEDevice> to_close;
            currently_connecting_devices_.erase(std::remove_if(currently_connecting_devices_.begin(), currently_connecting_devices_.end(),
                [&](const auto& pair) {
                    if (pair.first == remote_id) {
                        try { if (auto device = pair.second.as<BluetoothLEDevice>()) to_close.push_back(device); } catch(...) {}
                        return true;
                    }
                    return false;
                }), currently_connecting_devices_.end());

            connected_devices_.erase(std::remove_if(connected_devices_.begin(), connected_devices_.end(),
                [&](const auto& pair) {
                    if (pair.first == remote_id) {
                        try { if (auto device = pair.second.as<BluetoothLEDevice>()) to_close.push_back(device); } catch(...) {}
                        return true;
                    }
                    return false;
                }), connected_devices_.end());

            for (auto& d : to_close) { try { d.Close(); } catch(...) {} }

            ClearDeviceResources(remote_id);

            flutter::EncodableMap connection_state; connection_state[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id); connection_state[flutter::EncodableValue("connection_state")] = flutter::EncodableValue(0); 
            channel_->InvokeMethod("OnConnectionStateChanged", std::make_unique<flutter::EncodableValue>(connection_state));
        }
        result->Success(flutter::EncodableValue(true)); return;
    }
    if (method == "discoverServices") {
        const auto* remote_id_val = std::get_if<std::string>(method_call.arguments());
        if (remote_id_val) DiscoverServicesAsync(*remote_id_val, std::move(result));
        else result->Error("discoverServices", "Invalid arguments");
        return;
    }
    if (method == "setNotifyValue") {
        const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (args) { auto args_ptr = std::make_shared<flutter::EncodableMap>(*args); result->Success(flutter::EncodableValue(true)); SetNotifyValueAsync(args_ptr); }
        else result->Error("setNotifyValue", "Invalid arguments");
        return;
    }
    if (method == "readCharacteristic") {
        const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (args) ReadCharacteristicAsync(*args, std::move(result)); else result->Error("readCharacteristic", "Invalid arguments");
        return;
    }
    if (method == "writeCharacteristic") {
        const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (args) WriteCharacteristicAsync(*args, std::move(result)); else result->Error("writeCharacteristic", "Invalid arguments");
        return;
    }
    if (method == "readDescriptor") {
        const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (args) ReadDescriptorAsync(*args, std::move(result)); else result->Error("readDescriptor", "Invalid arguments");
        return;
    }
    if (method == "writeDescriptor") {
        const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (args) WriteDescriptorAsync(*args, std::move(result)); else result->Error("writeDescriptor", "Invalid arguments");
        return;
    }
    if (method == "setLogLevel") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "setOptions") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "isSupported") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "requestMtu") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "requestConnectionPriority") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "setPreferredPhy") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "turnOn") { result->Success(flutter::EncodableValue(false)); return; }
    if (method == "turnOff") { result->Success(flutter::EncodableValue(false)); return; }
    if (method == "clearGattCache") { result->Success(flutter::EncodableValue(true)); return; }
    if (method == "getPhySupport") { 
        flutter::EncodableMap response;
        response[flutter::EncodableValue("le_2m")] = flutter::EncodableValue(true);
        response[flutter::EncodableValue("le_coded")] = flutter::EncodableValue(true);
        result->Success(flutter::EncodableValue(response)); 
        return; 
    }
    if (method == "getBondedDevices") {
        flutter::EncodableMap response;
        response[flutter::EncodableValue("devices")] = flutter::EncodableList{};
        result->Success(flutter::EncodableValue(response));
        return;
    }
    if (method == "connectedCount") { result->Success(flutter::EncodableValue(static_cast<int>(connected_devices_.size()))); return; }
    if (method == "readRssi") {
        const auto* remote_id_arg = std::get_if<std::string>(method_call.arguments());
        if (remote_id_arg) {
            std::string remote_id = *remote_id_arg;
            flutter::EncodableMap rssi_result;
            rssi_result[flutter::EncodableValue("remote_id")] = flutter::EncodableValue(remote_id);
            rssi_result[flutter::EncodableValue("error_code")] = flutter::EncodableValue(0);
            rssi_result[flutter::EncodableValue("error_string")] = flutter::EncodableValue("GATT_SUCCESS");
            
            auto it = rssi_cache_.find(remote_id);
            if (it != rssi_cache_.end()) {
                rssi_result[flutter::EncodableValue("rssi")] = flutter::EncodableValue(it->second);
                rssi_result[flutter::EncodableValue("success")] = flutter::EncodableValue(1);
            } else {
                rssi_result[flutter::EncodableValue("rssi")] = flutter::EncodableValue(0);
                rssi_result[flutter::EncodableValue("success")] = flutter::EncodableValue(0);
                rssi_result[flutter::EncodableValue("error_code")] = flutter::EncodableValue(1);
                rssi_result[flutter::EncodableValue("error_string")] = flutter::EncodableValue("RSSI not cached");
            }
            channel_->InvokeMethod("OnReadRssi", std::make_unique<flutter::EncodableValue>(rssi_result));
            result->Success(flutter::EncodableValue(true));
        } else result->Error("readRssi", "Invalid arguments");
        return;
    }

    result->NotImplemented();
}

}  // namespace flutter_blue_plus_winrt

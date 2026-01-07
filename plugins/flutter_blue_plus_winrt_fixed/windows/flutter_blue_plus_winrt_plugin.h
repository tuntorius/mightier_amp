#ifndef FLUTTER_PLUGIN_FLUTTER_BLUE_PLUS_WINRT_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_BLUE_PLUS_WINRT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <winrt/Windows.Devices.Bluetooth.Advertisement.h>
#include <winrt/Windows.Devices.Bluetooth.h>
#include <winrt/Windows.Devices.Bluetooth.GenericAttributeProfile.h>
#include <winrt/Windows.Foundation.h>

#include <memory>
#include <string>
#include <vector>
#include <utility>
#include <map>
#include <atomic>

namespace flutter_blue_plus_winrt {

struct SubscribedCharacteristic {
    winrt::Windows::Foundation::IInspectable characteristic = nullptr;
    winrt::event_token token;
};

class FlutterBluePlusWinrtPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterBluePlusWinrtPlugin(flutter::PluginRegistrarWindows* registrar);

  ~FlutterBluePlusWinrtPlugin();

  // Disallow copy and assign.
  FlutterBluePlusWinrtPlugin(const FlutterBluePlusWinrtPlugin&) = delete;
  FlutterBluePlusWinrtPlugin& operator=(const FlutterBluePlusWinrtPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;

  winrt::Windows::Devices::Bluetooth::Advertisement::BluetoothLEAdvertisementWatcher watcher_{};
  winrt::event_token received_token_{};
  winrt::event_token stopped_token_{};
  
  std::atomic<bool> is_alive_{ true };

  // UI Thread context
  winrt::apartment_context ui_thread_;

  std::vector<std::pair<std::string, winrt::Windows::Foundation::IInspectable>> connected_devices_{};
  std::vector<std::pair<std::string, winrt::Windows::Foundation::IInspectable>> currently_connecting_devices_{};
  std::map<std::string, int32_t> rssi_cache_{};
  
  std::map<std::string, std::map<flutter::EncodableValue, flutter::EncodableValue>> scan_results_cache_{};

  // Map to store event tokens and characteristic objects for notifications
  std::map<std::string, SubscribedCharacteristic> subscribed_characteristics_{};

  // Caches for GATT objects to avoid repeated discovery
  std::map<std::string, winrt::Windows::Foundation::IInspectable> characteristic_cache_{};
  std::map<std::string, winrt::Windows::Foundation::IInspectable> descriptor_cache_{};
  std::map<std::string, std::vector<winrt::Windows::Foundation::IInspectable>> service_cache_{};

  void OnAdvertisementReceived(
      const winrt::Windows::Devices::Bluetooth::Advertisement::BluetoothLEAdvertisementWatcher&,
      const winrt::Windows::Devices::Bluetooth::Advertisement::BluetoothLEAdvertisementReceivedEventArgs&);

  void OnAdvertisementStopped(
      const winrt::Windows::Devices::Bluetooth::Advertisement::BluetoothLEAdvertisementWatcher&,
      const winrt::Windows::Devices::Bluetooth::Advertisement::BluetoothLEAdvertisementWatcherStoppedEventArgs&);
  
  winrt::fire_and_forget GetSystemDevicesAsync(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  winrt::fire_and_forget GetAdapterStateAsync(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  winrt::fire_and_forget ConnectAsync(
      std::string remote_id,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  winrt::fire_and_forget DiscoverServicesAsync(
      std::string remote_id,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  
  winrt::fire_and_forget SetNotifyValueAsync(
      std::shared_ptr<flutter::EncodableMap> args);

  winrt::fire_and_forget ReadCharacteristicAsync(
      flutter::EncodableMap args,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  winrt::fire_and_forget WriteCharacteristicAsync(
      flutter::EncodableMap args,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  winrt::fire_and_forget ReadDescriptorAsync(
      flutter::EncodableMap args,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  winrt::fire_and_forget WriteDescriptorAsync(
      flutter::EncodableMap args,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void OnConnectionStatusChanged(
    const winrt::Windows::Devices::Bluetooth::BluetoothLEDevice&,
    const winrt::Windows::Foundation::IInspectable&);

  void OnCharacteristicValueChanged(
      std::string remote_id,
      const winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic& sender,
      const winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattValueChangedEventArgs& args);

  winrt::fire_and_forget PeriodicConnectionCheck();

  std::string uint64_to_mac_string(uint64_t addr);

  // --- Private GATT Helpers ---
  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic> 
  GetCharacteristicInternalAsync(
      winrt::Windows::Devices::Bluetooth::BluetoothLEDevice device,
      std::string remote_id,
      std::string service_uuid_str,
      std::string characteristic_uuid_str,
      std::string primary_service_uuid_str,
      int instance_id);

  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic> 
  GetCharacteristicByHandleAsync(
      winrt::Windows::Devices::Bluetooth::BluetoothLEDevice device,
      int instance_id);

  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic> 
  GetCharacteristicAsync(
      winrt::Windows::Devices::Bluetooth::BluetoothLEDevice device,
      std::string service_uuid_str,
      std::string characteristic_uuid_str,
      std::string primary_service_uuid_str,
      int instance_id);

  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic> 
  FindCharacteristicInServiceAsync(
      winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattDeviceService service,
      int instance_id,
      winrt::Windows::Devices::Bluetooth::BluetoothCacheMode cacheMode);

  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic> 
  FindCharacteristicByDescriptorHandleInServiceAsync(
      winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattDeviceService service,
      int descriptor_handle,
      winrt::Windows::Devices::Bluetooth::BluetoothCacheMode cacheMode);

  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic> 
  GetCharacteristicByDescriptorHandleAsync(
      winrt::Windows::Devices::Bluetooth::BluetoothLEDevice device,
      int descriptor_handle);

  winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattDescriptor> 
  GetDescriptorAsync(
      winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattCharacteristic characteristic,
      std::string descriptor_uuid_str);

  winrt::Windows::Foundation::IAsyncAction PopulateCharacteristicsAsync(
      winrt::Windows::Devices::Bluetooth::GenericAttributeProfile::GattDeviceService service,
      std::string remote_id,
      std::string primaryServiceUuid,
      std::shared_ptr<flutter::EncodableList> outList);

  void ClearDeviceResources(std::string remote_id);
};

}  // namespace flutter_blue_plus_winrt

#endif  // FLUTTER_PLUGIN_FLUTTER_BLUE_PLUS_WINRT_PLUGIN_H_

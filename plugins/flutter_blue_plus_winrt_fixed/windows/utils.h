#pragma once

#include <string>
#include <vector>
#include <algorithm>
#include <sstream>
#include <iomanip>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Storage.Streams.h>
#include <flutter/encodable_value.h>

namespace utils {

inline std::string to_string(winrt::hstring const& hstr) {
    return winrt::to_string(hstr);
}

inline std::string to_uuid_string(winrt::guid const& guid) {
    char buf[40];
    sprintf_s(buf, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
        guid.Data1, guid.Data2, guid.Data3,
        guid.Data4[0], guid.Data4[1], guid.Data4[2], guid.Data4[3],
        guid.Data4[4], guid.Data4[5], guid.Data4[6], guid.Data4[7]);
    return std::string(buf);
}

inline winrt::guid parse_uuid(std::string const& str) {
    unsigned int d1, d2, d3, d4[8];
    if (sscanf_s(str.c_str(), "%8x-%4x-%4x-%2x%2x-%2x%2x%2x%2x%2x%2x",
        &d1, &d2, &d3,
        &d4[0], &d4[1], &d4[2], &d4[3], &d4[4], &d4[5], &d4[6], &d4[7]) == 11) {
        return winrt::guid(d1, (uint16_t)d2, (uint16_t)d3, 
            {(uint8_t)d4[0], (uint8_t)d4[1], (uint8_t)d4[2], (uint8_t)d4[3], 
             (uint8_t)d4[4], (uint8_t)d4[5], (uint8_t)d4[6], (uint8_t)d4[7]});
    }
    return winrt::guid();
}

inline std::vector<uint8_t> to_vector(winrt::Windows::Storage::Streams::IBuffer const& buffer) {
    auto reader = winrt::Windows::Storage::Streams::DataReader::FromBuffer(buffer);
    std::vector<uint8_t> data(reader.UnconsumedBufferLength());
    if (data.size() > 0)
        reader.ReadBytes(data);
    return data;
}

template <typename T>
T from_value(flutter::EncodableValue* val) {
    if (!val) return T();
    if (auto* v = std::get_if<T>(val)) return *v;
    return T();
}

inline uint64_t mac_to_uint64(std::string const& mac) {
    uint64_t addr = 0;
    std::string hex = mac;
    hex.erase(std::remove(hex.begin(), hex.end(), ':'), hex.end());
    std::stringstream ss;
    ss << std::hex << hex;
    ss >> addr;
    return addr;
}

}

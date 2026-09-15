#
# macOS port of the vendored flutter_blue_plus 1.4.0 iOS plugin.
# Reuses the same CoreBluetooth + protobuf implementation.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_blue_plus'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for connecting and communicating with Bluetooth Low Energy devices'
  s.description      = <<-DESC
Flutter plugin for connecting and communicating with Bluetooth Low Energy devices on macOS via CoreBluetooth.
                       DESC
  s.homepage         = 'https://github.com/boskokg/flutter_blue_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bosko Popovic' => 'boskokg@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'gen/**/*'
  s.public_header_files = 'Classes/**/*.h', 'gen/**/*.h'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '12.0'
  s.framework = 'CoreBluetooth'

  s.subspec "Protos" do |ss|
    ss.source_files = "gen/*.pbobjc.{h,m}", "gen/**/*.pbobjc.{h,m}"
    ss.header_mappings_dir = "gen"
    ss.requires_arc = false
    ss.dependency "Protobuf", '~> 3.11'
  end

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1', }
end

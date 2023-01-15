package com.tuntori.mighty_ble;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothStatusCodes;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanRecord;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.ParcelUuid;
import android.os.Build;
import android.util.Log;

import java.util.List;
import java.util.HashMap;
import java.util.Queue;
import java.util.UUID;
import java.util.LinkedList;


public class BLEManager {
    private static final String TAG = "BLEManager";

    // UUIDs for the service and characteristics we are interested in
    private static final UUID MIDI_SERVICE_UUID = UUID.fromString("03b80e5a-ede8-4b33-a751-6ce34ec4c700");
    private static final UUID MIDI_CHARACTERISTIC_UUID = UUID.fromString("7772e5db-3868-4112-a1a9-f2669d106bf3");

    // Request code for enabling Bluetooth
    private static final int REQUEST_ENABLE_BT = 1;

    //a hashmap containing result from a scan, a pair of mac addr and device
    private final HashMap<String, BluetoothDevice> mScanResults = new HashMap<>();

    //a hashmap containing the connected devices
    private final HashMap<String, BluetoothGatt> mConnectedDevices = new HashMap<>();

    //a hashmap containing the midi characteristics
    private final HashMap<String, BluetoothGattCharacteristic> mCharacteristics = new HashMap<>();
    
    private final Queue<byte[]> mWriteQueue = new LinkedList<byte[]>();
    private boolean mIsWriting = false;

    private Context context;
    private MightyBlePlugin pluginHandler;

    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mBluetoothLeScanner;

    private boolean mScanning = false;

    public BLEManager(Context context, MightyBlePlugin pluginHandler)
    {
        this.context = context;
        this.pluginHandler = pluginHandler;
    }

    public void init()
    {
        final BluetoothManager bluetoothManager =
                (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = bluetoothManager.getAdapter();

        // Initialize the Bluetooth LE scanner
        mBluetoothLeScanner = mBluetoothAdapter.getBluetoothLeScanner();
    }

    public boolean isAvailable()
    {
        return context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE);
    }

    public void startScan() {
        if (mScanning)
            return;

        mScanning = true;
        mScanResults.clear();
        
        // Start scanning for devices
        mBluetoothLeScanner.startScan(mScanCallback);
    }

    public void stopScan() {
        if (!mScanning)
            return;

        mScanning = false;
        mBluetoothLeScanner.stopScan(mScanCallback);
    }

    public void connect(String address) {
        stopScan();

        if (mScanResults.containsKey(address))
        {
            BluetoothDevice device = mScanResults.get(address);
            device.connectGatt(context, false, mGattCallback);
        }
    }

    public void disconnect(String address) {
        if (mConnectedDevices.containsKey(address)) {
            BluetoothGatt gatt = mConnectedDevices.get(address);
            mIsWriting = false;
            mWriteQueue.clear();
            if (gatt != null) {
                gatt.disconnect();
                gatt.close();
            }
            mConnectedDevices.remove(address);
            mCharacteristics.remove(address);
        }
    }

    public void setNotificationEnabled(String address, boolean enabled)
    {
        if (!mConnectedDevices.containsKey(address) ||
         !mCharacteristics.containsKey(address))
         {
            Log.w(TAG, "conn dev " + mConnectedDevices.containsKey(address) +
                 " chars " + mCharacteristics.containsKey(address));
            return;
         }

        BluetoothGatt gatt = mConnectedDevices.get(address);
        BluetoothGattCharacteristic characteristic = mCharacteristics.get(address);
        gatt.setCharacteristicNotification(characteristic, enabled);
    }
    
    public int write(String address, byte[] data) {
        
        if (!mConnectedDevices.containsKey(address) ||
         !mCharacteristics.containsKey(address))
         {
            Log.w(TAG, "conn dev " + mConnectedDevices.containsKey(address) +
                 " chars " + mCharacteristics.containsKey(address));
            return 0;
         }

        synchronized (this) {
            if (mIsWriting) {
                mWriteQueue.add(data);
                return 0;
            }
            mIsWriting = true;
        }

        BluetoothGatt gatt = mConnectedDevices.get(address);
        BluetoothGattCharacteristic characteristic = mCharacteristics.get(address);
        
        writeNext(gatt, characteristic, data);

        // if (mConnectedDevices.containsKey(address) &&
        //  mCharacteristics.containsKey(address)){
        //     BluetoothGatt gatt = mConnectedDevices.get(address);
        //     BluetoothGattCharacteristic characteristic = mCharacteristics.get(address);
        //     mWriteQueue.add(data);
        //     writeNext(gatt, characteristic);
        // }
        // else {
            
        // }
        return 0;
    }

    private int writeNext(BluetoothGatt gatt, 
                BluetoothGattCharacteristic characteristic, byte[] value) {
        // if (mIsWriting || mWriteQueue.isEmpty()) {
        //     if (mWriteQueue.isEmpty())
        //         Log.d(TAG, "Queue exhausted.");
        //     return 0;
        // }
        
        // mIsWriting = true;
        // byte[] value = mWriteQueue.poll();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
        {
            int success = gatt.writeCharacteristic(characteristic, value, BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
            if (success != BluetoothStatusCodes.SUCCESS) {
                Log.d(TAG, "writeCharacteristic failed with value " + success);
            }
            return 0;
        }
        
        //legacy code (< 33) here
        characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);

        boolean success = characteristic.setValue(value);
        if (!success) {
            Log.d(TAG, "SetValue failed");
            return 1;
        }
        success = gatt.writeCharacteristic(characteristic);
        if (!success) {
            Log.d(TAG, "writeCharacteristic failed");
        }
        return 0;

        // int errcode = mBluetoothGatt.writeCharacteristic (midiCharacteristic, 
        //                     data, 
        //                     BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
        //return errcode;
    }

    // Callback for receiving BLE scan results
    private ScanCallback mScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            Log.d(TAG, "onScanResult: " + result.getDevice().getAddress());

            // Check if the device name matches the name of the device we are looking for
            if (result.getDevice().getName()!=null) {
                boolean hasMidiService = false;
                //check if it contains the midi service id
                ScanRecord scanRecord = result.getScanRecord();
                List<ParcelUuid> serviceUuids = scanRecord.getServiceUuids();
                
                // Convert UUID to ParcelUuid
                ParcelUuid midiParcelUuid = ParcelUuid.fromString(MIDI_SERVICE_UUID.toString());

                if (serviceUuids.contains(midiParcelUuid)) {
                    hasMidiService = true;
                }

                String address = result.getDevice().getAddress();
                //add to result list
                if (!mScanResults.containsKey(address))
                mScanResults.put(address, result.getDevice());

                //notify about result
                pluginHandler.onScanResult(result.getDevice().getName(), address, hasMidiService);
            }
        }
    };

    // Callback for receiving GATT events
    private BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            if (newState == BluetoothGatt.STATE_CONNECTED) {
                Log.d(TAG, "Connected to GATT server.");
                
                // Discover services
                gatt.discoverServices();
            } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                Log.d(TAG, "Disconnected from GATT server.");

                String address = gatt.getDevice().getAddress();
                mConnectedDevices.remove(address);

                if (mCharacteristics.containsKey(address))
                    mCharacteristics.remove(address);

                //notify about the disconnect
                pluginHandler.onDisconnected(address);
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Services discovered.");

                // Get the service we are interested in
                BluetoothGattService service = gatt.getService(MIDI_SERVICE_UUID);
                if (service != null) {
                    // Get the characteristic we are interested in
                    BluetoothGattCharacteristic characteristic = service.getCharacteristic(MIDI_CHARACTERISTIC_UUID);
                    if (characteristic != null) {
                        // Enable notifications for the characteristic
                        gatt.setCharacteristicNotification(characteristic, true);
                        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(
                                UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"));

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                        {
                            gatt.writeDescriptor(descriptor, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        }
                        else {
                            descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                            gatt.writeDescriptor(descriptor);
                        }
                        

                        //store in connected devices
                        String address = gatt.getDevice().getAddress();
                        mConnectedDevices.put(address, gatt);

                        mCharacteristics.put(address, characteristic);

                        //notify about the successful connection
                        pluginHandler.onConnected(address);
                    }
                }
            } else {
                Log.w(TAG, "onServicesDiscovered received: " + status);
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            // We received a notification for the characteristic we are interested in
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                String address = gatt.getDevice().getAddress();
                byte[] value = characteristic.getValue();
                //Log.d(TAG, "Received notification: " + bytesToHex( value ));
                pluginHandler.onCharacteristicNotify(address, value);
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, byte[] value) {
            // We received a notification for the characteristic we are interested in
            String address = gatt.getDevice().getAddress();
            pluginHandler.onCharacteristicNotify(address, value);
        }
        
        @Override
        public void onCharacteristicWrite (BluetoothGatt gatt, 
                BluetoothGattCharacteristic characteristic, 
                int status)
        {
            Log.e(TAG, "Characteristic write " + status);
            // mIsWriting = false;
            // writeNext(gatt, characteristic);

            byte[] message;
            synchronized (this) {
                if (mWriteQueue.isEmpty()) {
                    mIsWriting = false;
                    return;
                }
                message = mWriteQueue.poll();
            }
            writeNext(gatt, characteristic, message);

        }
    };
}
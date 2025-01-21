package com.aeologic.adhoc.qr_utils;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.aeologic.adhoc.qr_utils.activity.QRScannerActivity;
import com.aeologic.adhoc.qr_utils.utils.Utility;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Reader;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;

import java.io.ByteArrayOutputStream;
import java.util.List;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * QrUtilsPlugin
 */
public class QrUtilsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String TAG = QrUtilsPlugin.class.getSimpleName();
    private static final String METHOD_CHANNEL = "com.aeologic.adhoc.qr_utils";

    private MethodChannel channel;
    private Activity activity;
    private Result pendingResult;
    private int requestID;
    private static final int REQUEST_SCAN_QR = 0x1000001;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener((requestCode, resultCode, data) -> onActivityResult(requestCode, resultCode, data));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        this.pendingResult = result;
        if (call.method.equals("scanQR")) {
            requestID = REQUEST_SCAN_QR;
            checkPermission();
        } else if (call.method.equals("scanImage")) {
            byte[] data = call.argument("data");
            String qrData = scanQRImage(data);
            result.success(qrData);
        } else if (call.method.equals("generateQR")) {
            String content = call.argument("content");
            generateQR(content);
        } else {
            result.notImplemented();
        }
    }

    private void checkPermission() {
        Dexter.withActivity(activity)
                .withPermissions(Manifest.permission.CAMERA)
                .withListener(new MultiplePermissionsListener() {
                    @Override
                    public void onPermissionsChecked(MultiplePermissionsReport report) {
                        if (report.areAllPermissionsGranted()) {
                            if (requestID == REQUEST_SCAN_QR) {
                                scanQR();
                            }
                        } else {
                    Toast.makeText(activity, activity.getString(R.string.grant_all_permission), Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(List<PermissionRequest> permissions, PermissionToken token) {
                        token.continuePermissionRequest();
                    }
                }).check();
    }

    private String scanQRImage(byte[] data) {
        Bitmap bMap = BitmapFactory.decodeByteArray(data, 0, data.length);
        String contents = null;
        int[] intArray = new int[bMap.getWidth() * bMap.getHeight()];
        bMap.getPixels(intArray, 0, bMap.getWidth(), 0, 0, bMap.getWidth(), bMap.getHeight());
        LuminanceSource source = new RGBLuminanceSource(bMap.getWidth(), bMap.getHeight(), intArray);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
        Reader reader = new MultiFormatReader();
        try {
            com.google.zxing.Result result = reader.decode(bitmap);
            contents = result.getText();
        } catch (Exception e) {
            Log.e(TAG, "Error decoding QR code", e);
        }
        return contents;
    }

    private void generateQR(final String content) {
        new Thread(() -> {
            try {
                final Bitmap qrBmp = Utility.generateQRCode(content);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                qrBmp.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
                final byte[] byteArray = byteArrayOutputStream.toByteArray();
                final String qrBase64 = Base64.encodeToString(byteArray, Base64.DEFAULT);
                activity.runOnUiThread(() -> pendingResult.success(byteArray));
            } catch (Exception e) {
                activity.runOnUiThread(() -> Toast.makeText(activity, "QR code generation failed.", Toast.LENGTH_SHORT).show());
                Log.e(TAG, "Error generating QR code", e);
            }
        }).start();
    }

    private void scanQR() {
        Intent intent = new Intent(activity, QRScannerActivity.class);
        activity.startActivityForResult(intent, REQUEST_SCAN_QR);
    }

    private boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_SCAN_QR) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                String content = data.getStringExtra(QRScannerActivity.QR_CONTENT);
                pendingResult.success(content);
            } else {
                pendingResult.success(null);
            }
            return true;
        }
        return false;
    }
}

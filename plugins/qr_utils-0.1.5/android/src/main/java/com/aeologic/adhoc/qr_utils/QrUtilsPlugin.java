package com.aeologic.adhoc.qr_utils;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import com.aeologic.adhoc.qr_utils.activity.QRScannerActivity;
import com.aeologic.adhoc.qr_utils.utils.Utility;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.List;
import java.io.InputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;
import static com.aeologic.adhoc.qr_utils.activity.QRScannerActivity.QR_CONTENT;

import com.google.zxing.LuminanceSource;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Reader;

/**
 * QrUtilsPlugin
 */
public class QrUtilsPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
    /**
     * Plugin registration.
     */
    private static final String TAG = QrUtilsPlugin.class.getSimpleName();
    private static final String METHOD_CHANNEL = "com.aeologic.adhoc.qr_utils";
    private Result result;
    private int requestID = 0;
    private static final int REQUEST_SCAN_QR = 0x1000001;
    private static final int REQUEST_GENERATE_QR = 0x1000002;


    private Activity activity;

    public QrUtilsPlugin(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
        QrUtilsPlugin cameraPlugin = new QrUtilsPlugin(registrar.activity());
        registrar.addActivityResultListener(cameraPlugin);
        channel.setMethodCallHandler(cameraPlugin);
    }

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        this.result = result;
        if (call.method.equals("scanQR")) {
            requestID = REQUEST_SCAN_QR;
            checkPermission();
        }
        else if (call.method.equals("scanImage"))
        {
            byte[] data = call.argument("data");
            String qrdata = scanQRImage(data);
            result.success(qrdata);
        } else if (call.method.equals("generateQR")) {
            requestID = REQUEST_GENERATE_QR;
            String content = call.argument("content");
            Log.v(TAG, "QR_CONTENT: " + content);
            generateQR(content);
        } else {
            result.notImplemented();
        }
    }

    private void checkPermission() {
        Dexter.withActivity(activity)
                .withPermissions(
                        Manifest.permission.CAMERA
                ).withListener(new MultiplePermissionsListener() {
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
        //bMap = Bitmap.createScaledBitmap(bMap,parent.getWidth(),parent.getHeight(),true);
        //imageView.setImageBitmap(bMap);

        String contents = null;

        int[] intArray = new int[bMap.getWidth()*bMap.getHeight()];
        //copy pixel data from the Bitmap into the 'intArray' array
        bMap.getPixels(intArray, 0, bMap.getWidth(), 0, 0, bMap.getWidth(), bMap.getHeight());

        LuminanceSource source = new RGBLuminanceSource(bMap.getWidth(), bMap.getHeight(), intArray);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));

        Reader reader = new MultiFormatReader();
        try {
            com.google.zxing.Result result = reader.decode(bitmap);
            contents = result.getText();
        }
        catch (Exception e) {
            Log.e("qr_utils", "Error decoding qr code", e);
        }
        return contents;
    }

    private void generateQR(final String content) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    final Bitmap qrBmp = Utility.generateQRCode(content);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    qrBmp.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
                    final byte[] byteArray = byteArrayOutputStream.toByteArray();
                    final String qrBase64 = Base64.encodeToString(byteArray, Base64.DEFAULT);
                    activity.runOnUiThread(new Runnable() {
                        public void run() {
                            Log.v(TAG, "QR_BASE_64: " + qrBase64);
                            result.success(byteArray);
                            //qrBmp
                            //
                        }
                    });
                } catch (Exception e) {
                    activity.runOnUiThread(new Runnable() {
                        public void run() {
                            Toast.makeText(activity, activity.getString(R.string.process_failed), Toast.LENGTH_SHORT).show();
                        }
                    });
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private void scanQR() {
        Intent intent = new Intent(activity, QRScannerActivity.class);
        activity.startActivityForResult(intent, REQUEST_SCAN_QR);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.v(TAG, "onActivityResult()");
        if (requestCode == REQUEST_SCAN_QR) {
            if (resultCode == RESULT_OK) {
                if (data != null) {
                    String content = data.getStringExtra(QR_CONTENT);
                    Log.v(TAG, "QR_CONTENT: " + content);
                    result.success(content);
                }
            } else if (resultCode == RESULT_CANCELED) {
                result.success(null);
            }
        }
        return false;
    }
}
package com.aeologic.adhoc.qr_utils.activity;


import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.Toast;
import android.graphics.Color;

import com.aeologic.adhoc.qr_utils.R;
import com.google.zxing.Result;

import me.dm7.barcodescanner.zxing.ZXingScannerView;

import static com.aeologic.adhoc.qr_utils.utils.Utility.isDrawablesIdentical;

/**
 * Created by Deepak on 06-Jul-17.
 */

public class QRScannerActivity extends AppCompatActivity implements View.OnClickListener, ZXingScannerView.ResultHandler {
    private static final String TAG = QRScannerActivity.class.getSimpleName();
    private ZXingScannerView mScannerView;
    private ViewGroup contentFrame;
    private ImageView flashImg;

    public static final String QR_CONTENT = "QR_CONTENT";

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setContentView(R.layout.activity_qr_scanner);
        initViews();
        /*setupToolbar();
         setupStatusBarColor();*/
        mScannerView = new ZXingScannerView(this);
        mScannerView.setLaserEnabled(false);
        mScannerView.setSquareViewFinder(true);
        contentFrame.addView(mScannerView);
        flashImg.setOnClickListener(this);
    }

    private void initViews() {
        contentFrame = findViewById(R.id.content_frame);
        flashImg = findViewById(R.id.flash_img);
    }

    @Override
    public void onClick(View view) {
        if (view == flashImg) {
            if (isDrawablesIdentical(flashImg.getDrawable(), getResources().getDrawable(R.drawable.ic_flash_active))) {
                flashImg.setImageDrawable(getResources().getDrawable(R.drawable.ic_flash_inactive));
                startFlash(false);
            } else if (isDrawablesIdentical(flashImg.getDrawable(), getResources().getDrawable(R.drawable.ic_flash_inactive))) {
                flashImg.setImageDrawable(getResources().getDrawable(R.drawable.ic_flash_active));
                startFlash(true);
            }
        }
    }

    private void startFlash(boolean status) {
        mScannerView.setFlash(status);
    }

    private void setupToolbar() {
        //Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        //setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        setTitle(getString(R.string.qr_scanner));
    }

    private void setupStatusBarColor() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            //window.setStatusBarColor(getResources().getColor(R.color.blueDark));
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        mScannerView.setResultHandler(this);
        mScannerView.startCamera();
    }

    @Override
    public void onPause() {
        super.onPause();
        mScannerView.stopCamera();
    }

    @Override
    public void handleResult(Result rawResult) {
        /*Toast.makeText(this, "Contents = " + rawResult.getText() +
                ", Format = " + rawResult.getBarcodeFormat().toString(), Toast.LENGTH_SHORT).show();*/
        if (rawResult != null) {
            String qrContent = rawResult.getText();
            Log.v("CONTENT", "DATA: " + qrContent);
            Handler handler = new Handler();
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mScannerView.resumeCameraPreview(QRScannerActivity.this);
                }
            }, 2000);
            Intent intent = new Intent();
            intent.putExtra(QR_CONTENT, qrContent);
            setResult(RESULT_OK, intent);
            finish();

        } else {
            Log.v(TAG,"handleResult(_) => Process Failed");
            Toast.makeText(QRScannerActivity.this, getString(R.string.process_failed), Toast.LENGTH_SHORT).show();
            goToBack();
        }
    }

    @Override
    public void onBackPressed() {
        goToBack();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                goToBack();
                break;
        }
        return true;
    }

    private void goToBack() {
        Intent intent = new Intent();
        setResult(RESULT_CANCELED, intent);
        finish();
    }

}
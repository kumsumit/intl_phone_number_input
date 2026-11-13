package com.intlphonenumberinput;

import android.content.Context;
import android.telephony.TelephonyManager;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public final class IntlPhoneNumberInputPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    context = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(),
        "intl_phone_number_input/country_detector");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (!"getCountrySignals".equals(call.method)) {
      result.notImplemented();
      return;
    }

    Map<String, String> signals = new HashMap<>();
    try {
      TelephonyManager manager =
          (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
      if (manager != null) {
        putIfPresent(signals, "simCountry", manager.getSimCountryIso());
        putIfPresent(signals, "networkCountry", manager.getNetworkCountryIso());
      }
    } catch (SecurityException | UnsupportedOperationException ignored) {
      // Some devices restrict telephony metadata. Other signals still apply.
    }
    result.success(signals);
  }

  private static void putIfPresent(Map<String, String> values, String key, String value) {
    if (value != null && !value.trim().isEmpty()) values.put(key, value);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) channel.setMethodCallHandler(null);
    channel = null;
    context = null;
  }
}

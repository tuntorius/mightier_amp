class PresetEncoder {
  //The algorithm is super simple, but works better than any of the
  //standard algorithms like zlib,bzip etc...
  //the data is always 7 bit and quite often has long run of zeros
  //therefore I replace the run of zeros with a byte wiht highest bit set
  //and the run length. Even if there's just one zero, the run-lenght of it
  //doesn't take more space. For MPPro presets this achieves ~50% recduction
  static List<int> encode(List<int> data) {
    List<int> out = [];
    int zeroRle = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i] != 0) {
        out.add(data[i]);
      } else {
        zeroRle++;

        if (i == data.length - 1 || data[i + 1] != 0) {
          //end of zero run
          var rle = 0x80 | zeroRle;
          out.add(rle);
          zeroRle = 0;
        }
      }
    }
    print(
        "${data.length} vs ${out.length} R:${out.length / data.length * 100}");
    return out;
  }

  static List<int> decode(List<int> data) {
    List<int> decode = [];
    //decompress
    for (var i = 0; i < data.length; i++) {
      if (data[i] & 0x80 != 0) {
        int len = data[i] & 0x7f;
        for (var j = 0; j < len; j++) {
          decode.add(0);
        }
      } else {
        decode.add(data[i]);
      }
    }
    return decode;
  }
}

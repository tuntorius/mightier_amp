class AMDF {
  static const DEFAULT_MIN_FREQUENCY = 82.0;
  static const DEFAULT_MAX_FREQUENCY = 1000.0;
  static const DEFAULT_RATIO = 5.0;
  static const DEFAULT_SENSITIVITY = 0.1;

  double sampleRate = 0;
  List<double> amd = [];

  int maxPeriod = 0;
  int minPeriod = 0;
  double ratio = DEFAULT_RATIO;
  double sensitivity = DEFAULT_SENSITIVITY;

  var result;

  AMDF(int sampleRate, int bufferSize) {
    implement(
        sampleRate, bufferSize, DEFAULT_MIN_FREQUENCY, DEFAULT_MAX_FREQUENCY);
  }

  void implement(int sampleRate, int bufferSize, double minFrequency,
      double maxFrequency) {
    amd = List.filled(bufferSize, 0.0);
    ratio = DEFAULT_RATIO;
    sensitivity = DEFAULT_SENSITIVITY;
    maxPeriod = (sampleRate / minFrequency + 0.5).round();
    minPeriod = (sampleRate / maxFrequency + 0.5).round();
    result = new Map<String, dynamic>();
  }

  getPitch(List<dynamic> audioBuffer) {
    try {
      int t = 0;
      double f0 = -1.0;
      double minval = double.infinity;
      double maxval = double.negativeInfinity;

      //this or add 0 in the brackets
      List<double> frames1 = [];
      List<double> frames2 = [];
      List<double> calcSub = [];
      print(audioBuffer[0]);
      int maxShift = audioBuffer.length;

      for (int i = 0; i < maxShift; i++) {
        frames1 = List.filled(maxShift - i + 1, 0.0);
        frames2 = List.filled(maxShift - i + 1, 0.0);

        t = 0;
        for (int aux1 = 0; aux1 < maxShift - i; aux1++) {
          t = t + 1;
          frames1[t] = audioBuffer[aux1];
        }

        t = 0;
        for (int aux2 = i; aux2 < maxShift; aux2++) {
          t = t + 1;
          frames2[t] = audioBuffer[aux2];
        }

        int frameLength = frames1.length;
        calcSub = List.filled(frameLength, 0.0);
        for (int u = 0; u < frameLength; u++) {
          calcSub[u] = frames1[u] - frames2[u];
        }

        double summation = 0;
        for (int l = 0; l < frameLength; l++) {
          summation += (calcSub[l]).abs();
        }
        amd[i] = summation;
      }
      for (int j = minPeriod; j < maxPeriod; j++) {
        if (amd[j] < minval) {
          minval = amd[j];
        }
        if (amd[j] > maxval) {
          maxval = amd[j];
        }
      }
      int cutoff = ((sensitivity * (maxval - minval)) + minval).round();
      int j = minPeriod;

      while (j <= maxPeriod && (amd[j] > cutoff)) {
        j = j + 1;
      }

      double search_length = minPeriod / 2;
      minval = amd[j];
      int minpos = j;
      int i = j;
      while ((i < j + search_length) && (i <= maxPeriod)) {
        i = i + 1;
        if (amd[i] < minval) {
          minval = amd[i];
          minpos = i;
        }
      }
      if ((amd[minpos] * ratio).round() < maxval) {
        f0 = sampleRate / minpos;
      }
      return f0;
    } catch (ex, stacktrace) {
      print(stacktrace.toString());
    }
  }
}

class YIN {
  /**
	 * The default YIN threshold value. Should be around 0.10~0.15. See YIN
	 * paper for more information.
	 */
  static const DEFAULT_THRESHOLD = 0.20;

  /**
	 * The default size of an audio buffer (in samples).
	 */
  static const DEFAULT_BUFFER_SIZE = 2048;

  /**
	 * The actual YIN threshold.
	 */
  double threshold = DEFAULT_THRESHOLD;

  /**
	 * The audio sample rate. Most audio has a sample rate of 44.1kHz.
	 */
  late int sampleRate;

  /**
	 * The buffer that stores the calculated values. It is exactly half the size
	 * of the input buffer.
	 */
  late List<double> yinBuffer;

  /**
	 * Holds the FFT data, twice the length of the audio buffer.
	 */
  late List<double> audioBufferFFT;

  /**
	 * Half of the data, disguised as a convolution kernel.
	 */
  late List<double> kernel;

  /**
	 * Buffer to allow convolution via complex multiplication. It calculates the auto correlation function (ACF).
	 */
  late List<double> yinStyleACF;

  YIN(final int audioSampleRate, final int bufferSize) {
    this.sampleRate = audioSampleRate;
    var halfBufferSize = (bufferSize / 2).round();
    var doubleBufferSize = 2 * bufferSize;
    yinBuffer = List.filled(halfBufferSize, 0, growable: false);
    //Initializations for FFT difference step
    audioBufferFFT = List.filled(doubleBufferSize, 0, growable: false);
    kernel = List.filled(doubleBufferSize, 0, growable: false);
    yinStyleACF = List.filled(doubleBufferSize, 0, growable: false);
  }

  double getPitch(var audioBuffer) {
    int tauEstimate;
    try {
      double pitchInHertz;
      // step 2
      difference(audioBuffer);
      // step 3
      cumulativeMeanNormalizedDifference();
      // step 4
      tauEstimate = absoluteThreshold();
      // step 5
      if (tauEstimate != -1) {
        var betterTau = parabolicInterpolation(tauEstimate);
        // step 6
        // TODO Implement optimization for the AUBIO_YIN algorithm.
        // 0.77% => 0.5% error rate,
        // using the data of the YIN paper
        // bestLocalEstimate()

        // conversion to Hz
        pitchInHertz = sampleRate / betterTau;
      } else {
        // no pitch found
        pitchInHertz = -1;
      }

      return pitchInHertz;
    } catch (ex, stacktrace) {
      return -1;
    }
  }

  void difference(var audioBuffer) {
    int index, tau;
    double delta;
    for (tau = 0; tau < yinBuffer.length; tau++) {
      yinBuffer[tau] = 0;
    }
    for (tau = 1; tau < yinBuffer.length; tau++) {
      for (index = 0; index < yinBuffer.length; index++) {
        delta = audioBuffer[index] - audioBuffer[index + tau];
        yinBuffer[tau] += delta * delta;
      }
    }
  }

  /**
	 * The cumulative mean normalized difference function as described in step 3
	 * of the YIN paper. <br>
	 * <code>
	 * yinBuffer[0] == yinBuffer[1] = 1
	 * </code>
	 */
  void cumulativeMeanNormalizedDifference() {
    int tau;
    yinBuffer[0] = 1;
    double runningSum = 0;
    for (tau = 1; tau < yinBuffer.length; tau++) {
      runningSum += yinBuffer[tau];
      yinBuffer[tau] *= tau / runningSum;
    }
  }

  /**
	 * Implements step 4 of the AUBIO_YIN paper.
	 */
  int absoluteThreshold() {
    // Uses another loop construct
    // than the AUBIO implementation
    int tau;
    // first two positions in yinBuffer are always 1
    // So start at the third (index 2)
    var prob;
    for (tau = 2; tau < yinBuffer.length; tau++) {
      if (yinBuffer[tau] < threshold) {
        while (
            tau + 1 < yinBuffer.length && yinBuffer[tau + 1] < yinBuffer[tau]) {
          tau++;
        }
        // found tau, exit loop and return
        // store the probability
        // From the YIN paper: The threshold determines the list of
        // candidates admitted to the set, and can be interpreted as the
        // proportion of aperiodic power tolerated
        // within a periodic signal.
        //
        // Since we want the periodicity and and not aperiodicity:
        // periodicity = 1 - aperiodicity
        // result.setProbability(1 - yinBuffer[tau]);
        break;
      }
    }
    // if no pitch found, tau => -1
    if (tau == yinBuffer.length || yinBuffer[tau] >= threshold) {
      tau = -1;
      // result.setProbability(0);
      // result.setPitched(false);
    } else {
      // result.setPitched(true);
    }
    return tau;
  }

  /**
	 * Implements step 5 of the AUBIO_YIN paper. It refines the estimated tau
	 * value using parabolic interpolation. This is needed to detect higher
	 * frequencies more precisely. See http://fizyka.umk.pl/nrbook/c10-2.pdf and
	 * for more background
	 * http://fedc.wiwi.hu-berlin.de/xplore/tutorials/xegbohtmlnode62.html
	 * 
	 * @param tauEstimate
	 *            The estimated tau value.
	 * @return A better, more precise tau value.
	 */
  parabolicInterpolation(final int tauEstimate) {
    var betterTau;
    int x0;
    int x2;

    if (tauEstimate < 1) {
      x0 = tauEstimate;
    } else {
      x0 = tauEstimate - 1;
    }
    if (tauEstimate + 1 < yinBuffer.length) {
      x2 = tauEstimate + 1;
    } else {
      x2 = tauEstimate;
    }
    if (x0 == tauEstimate) {
      if (yinBuffer[tauEstimate] <= yinBuffer[x2]) {
        betterTau = tauEstimate;
      } else {
        betterTau = x2;
      }
    } else if (x2 == tauEstimate) {
      if (yinBuffer[tauEstimate] <= yinBuffer[x0]) {
        betterTau = tauEstimate;
      } else {
        betterTau = x0;
      }
    } else {
      double s0, s1, s2;
      s0 = yinBuffer[x0];
      s1 = yinBuffer[tauEstimate];
      s2 = yinBuffer[x2];
      // fixed AUBIO implementation, thanks to Karl Helgason:
      // (2.0f * s1 - s2 - s0) was incorrectly multiplied with -1
      betterTau = tauEstimate + (s2 - s0) / (2 * (2 * s1 - s2 - s0));
    }
    return betterTau;
  }
}

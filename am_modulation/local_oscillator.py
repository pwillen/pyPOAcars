import numpy as np


def local_oscillator(fc: float, fs: float, n_samples: int) -> np.ndarray:
    """
    Generate a local oscillator signal at the specified frequency and sample rate.

    NOTE fs must be greater than 2*fc to avoid aliasing.
    :param fc: Center Frequency
    :param fs: Sample Rate
    :param n_samples: Len of the signal
    :return: Local Oscillator Signal
    """
    if fs < 2 * fc:
        raise ValueError("Sample rate must be greater than 2*fc to avoid aliasing.")
    t = np.arange(n_samples) / fs
    return np.cos(2 * np.pi * fc * t)

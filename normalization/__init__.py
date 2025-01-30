import numpy as np


def normalize_signal(signal: np.ndarray) -> np.ndarray:
    """
    Normalize a signal to +/- 1.
    :param signal: The input signal to normalize.
    :return: The normalized signal.
    """
    signal = signal - np.mean(signal)
    signal = signal / np.max(np.abs(signal))

    return signal

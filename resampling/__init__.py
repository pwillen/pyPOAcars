import numpy as np
from scipy.signal import resample_poly


def resample(
    signal: np.ndarray, down: int, up: int, samples_per_symbol: int
) -> tuple[np.ndarray, int]:
    """
    Resample a signal
    :param signal: the signal to resample
    :param down: the sample rate of the signal
    :param up: the new sample rate of the signal
    :param samples_per_symbol: the number of samples per symbol
    :return: the resampled signal new sample rate and new samples per symbol
    """

    # Resample to new sample rate
    resampled_signal = resample_poly(signal, up, down)  # up, down

    resample_factor = down / up

    return resampled_signal, int(samples_per_symbol // resample_factor)

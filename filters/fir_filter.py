import numpy as np
from scipy.signal import firwin


def filter_taps(
    cutoff: float | np.ndarray, fs: float, num_taps: int = 101, **kwargs
) -> np.ndarray:
    """
    Create filter taps for a filter.
    :param cutoff: Cutoff frequency
    :param fs: Sample rate of signal to filter
    :param num_taps: Number of taps
    :param kwargs:
    :return: Filter taps
    """
    # Use Firwin function to generate taps
    taps = firwin(numtaps=num_taps, cutoff=cutoff, fs=fs, **kwargs).astype(np.float32)

    # Normalize the filter taps to avoid unity gain
    return taps / np.sum(taps)


def low_pass_filter(
    signal: np.ndarray,
    cutoff: float,
    fs: float,
    convolution_mode: str = "same",
    num_taps: int = 101,
    **kwargs,
) -> np.ndarray:
    """
    Apply a Low Pass Filter to a Signal
    :param signal: The Signal to filter
    :param cutoff: Cutoff frequency
    :param fs: Sample Rate of Signal to filter
    :param convolution_mode: Convolution Mode 'valid' 'same' or 'full'
    :param num_taps: Number of taps
    :param kwargs:
    :return: The Filtered Signal
    """

    # Generate Taps
    taps = filter_taps(cutoff=cutoff, fs=fs, num_taps=num_taps, **kwargs)

    # Convolve the Sin
    return np.convolve(signal, taps, mode=convolution_mode)

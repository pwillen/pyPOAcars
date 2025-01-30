import numpy as np


def decimate(
    signal, decimation_factor: int, fs: float, samples_per_symbol: int
) -> tuple[np.ndarray, float, int]:
    """
    Decimate a signal by a factor
    :param signal: The signal to decimate
    :param decimation_factor: The factor to decimate by
    :param fs: The sample rate of the signal. Ideally this should be divisible by the decimation factor
    :param samples_per_symbol: Number of samples per symbol. Ideally this should be divisible by the decimation factor
    :return: The decimated signal
    """

    return (
        signal[::decimation_factor],
        fs // decimation_factor,
        samples_per_symbol // decimation_factor,
    )

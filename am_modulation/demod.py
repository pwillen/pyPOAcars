import numpy as np


def am_sync_demodulate(
    modulated_signal: np.ndarray, carrier_oscillator: np.ndarray
) -> np.ndarray:
    """
    Synchronous Real Envelope Detection

    Sometimes called coherent detection, this method multiplies the modulated signal by the carrier oscillator.

    The complicated part of this detector is that the fc Hz carrier frequency of the received RF input signal must be regenerated (a process called "carrier recovery") within the envelope detector to provide the local oscillator's
    signal. Another complication is that the local oscillator output must be in-phase with the input RF signal's sinusoid.

    The construction of the carrier_oscillator must be precise.
    :param modulated_signal: the am modulated signal
    :param carrier_oscillator: a local oscillator with the same carrier frequency and in phase with the transmitted signal
    :return: am demodulated signal
    """

    # Multiply the modulated signal by the carrier oscillator
    return modulated_signal * carrier_oscillator


def am_rectified_async_demodulate(modulated_signal: np.ndarray) -> np.ndarray:
    """
    Asynchronous/NonCoherent Rectified/Full-Wave Envelope Detection

    This method rectifies the modulated signal by taking the absolute value of the signal.

    The rectified signal also needs to be low-pass filtered to remove the high-frequency carrier and leave only the envelope.
    :param modulated_signal: the am modulated signal
    :return: am demodulated signal
    """

    # Rectify the signal by taking the absolute value
    return np.abs(modulated_signal)


def am_squared_async_demodulate(modulated_signal: np.ndarray) -> np.ndarray:
    """
    Asynchronous/NonCoherent Squared/Square-Law Envelope Detection

    This method squares the modulated signal.

    The squared signal also needs to be low-pass filtered to remove the high-frequency carrier and leave only the envelope.
    :param modulated_signal: the am modulated signal
    :return: am demodulated signal
    """

    # Square the signal to remove the negative values
    return modulated_signal**2

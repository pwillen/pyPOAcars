import numpy as np


def am_modulate(
    transmit_signal: np.ndarray, carrier_oscillator: np.ndarray
) -> np.ndarray:
    """
    Amplitude Modulation
    :param transmit_signal: some signal to transmit over am
    :param carrier_oscillator: a local oscillator with the carrier frequency to modulate the transmit signal
    :return: the am modulated signal
    """
    # Multiply transmit signal by carrier oscillator
    return (1 + transmit_signal) * carrier_oscillator

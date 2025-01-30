import numpy as np
from matplotlib import pyplot as plt


def plot_fft(signal: np.ndarray, fs: float, order_mag: float = 1e3, title="") -> None:
    """
    Plot the FFT of a signal.
    :param signal: the signal to plot
    :param fs: the sample rate of the signal
    :param order_mag: the order of magnitude to use for the frequency axis
    :param title: the title of the plot
    :return:
    """

    if order_mag == 1e3:
        freq_suffix = "kHz"
    elif order_mag == 1e6:
        freq_suffix = "MHz"
    elif order_mag == 1e9:
        freq_suffix = "GHz"
    else:
        freq_suffix = "Hz"

    # MAG
    FFT = np.fft.fftshift(np.fft.fft(signal))
    f_mag = np.abs(FFT)
    f_phase = np.angle(FFT)
    f = np.linspace(fs / -2, fs / 2, len(f_mag)) / order_mag
    plt.plot(f, f_mag)
    plt.xlabel(f"Frequency [{freq_suffix}]")
    plt.ylabel(f"{title} Freq Mag")
    plt.show()

    # PHASE
    plt.plot(f, f_phase)
    plt.xlabel(f"Frequency [{freq_suffix}]")
    plt.ylabel(f"{title} Freq Phase")
    plt.show()


def plot_psd(signal: np.ndarray, fs: float, order_mag=1e3, title="") -> None:
    """
    Plot the PSD of a signal.
    :param signal: the signal to plot
    :param fs: the sample rate of the signal
    :param order_mag: the order of magnitude to use for the frequency axis
    :param title: the title of the plot
    :return:
    """

    if order_mag == 1e3:
        freq_suffix = "kHz"
    elif order_mag == 1e6:
        freq_suffix = "MHz"
    elif order_mag == 1e9:
        freq_suffix = "GHz"
    else:
        freq_suffix = "Hz"

    # PSD
    PSD = 10 * np.log10(np.abs(np.fft.fftshift(np.fft.fft(signal))) ** 2)
    PSD = PSD - np.max(PSD)
    f = np.linspace(fs / -2, fs / 2, len(PSD)) / order_mag  # kHz
    plt.plot(f, PSD)
    plt.xlabel(f"Frequency [{freq_suffix}]")
    plt.ylabel(f"{title} PSD")
    plt.show()


def plot_constellation(signal: np.ndarray, title="") -> None:
    """
    Plot the constellation of a signal.
    :param signal: the signal to plot
    :param title: the title of the plot
    :return:
    """
    plt.title(f"{title} Constellation")
    plt.plot(signal.real, signal.imag, ".")
    plt.xlabel("I")
    plt.ylabel("Q")
    plt.grid(True)
    plt.show()


def plot_shifted_constellation(signal: np.ndarray, shift: int, title="") -> None:
    """
    Plot the constellation of a signal.
    :param signal: the signal to plot
    :param shift: the amount to shift the signal
    :param title: the title of the plot
    :return:
    """
    plt.title(f"{title} Shifted Constellation")
    plt.plot(signal.real[:-shift], signal.imag[shift:], ".")
    plt.xlabel("I")
    plt.ylabel("Q")
    plt.grid(True)
    plt.show()


def plot_all(
    signal: np.ndarray, fs: float, shift: int, order_mag: float = 1e3, title=""
) -> None:
    """
    Plot all the characteristics of a signal.
    :param signal: the signal to plot
    :param fs: the sample rate of the signal
    :param shift: the amount to shift the signal for the constellation plot
    :param order_mag: the order of magnitude to use for the frequency axis
    :param title: Title Prefix
    :return:
    """
    plot_fft(signal, fs, order_mag, title)
    plot_psd(signal, fs, order_mag, title)
    plot_constellation(signal, title)
    plot_shifted_constellation(signal, shift, title)

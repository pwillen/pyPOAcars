from matplotlib import pyplot as plt
import numpy as np


def plot_signal_samples(signal, title, samples_per_symbol):
    plt.figure(figsize=(10, 4))
    plt.plot(signal, label='Real part')
    for j in range(0, len(signal), samples_per_symbol * 2):
        plt.axvline(x=j, color='black', linestyle='--', linewidth=0.7)
    # for j in range(samples_per_symbol, len(signal), samples_per_symbol * 2):
    #     plt.axvline(x=j, color='red', linestyle='--', linewidth=0.7)
    plt.title(title)
    plt.xlabel('Num Samples')
    plt.ylabel('Amplitude')
    plt.legend()
    plt.grid(True)
    plt.show()


def plot_signal(signal, title, fs):
    plt.figure(figsize=(10, 4))
    time = np.arange(len(signal)) / fs
    plt.plot(time, np.real(signal), label='Real part')
    plt.plot(time, np.imag(signal), label='Imaginary part', alpha=0.5)
    plt.title(title)
    plt.xlabel('Time (s)')
    plt.ylabel('Amplitude')
    plt.legend()
    plt.grid(True)
    plt.show()

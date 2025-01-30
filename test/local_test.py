import os

import numpy as np

import resampling
from am_modulation.demod import am_rectified_async_demodulate
from decimation import decimate
from filters.fir_filter import low_pass_filter
from scipy.signal import resample
from scipy.io import wavfile

from normalization import normalize_signal
from plotting import plot_signal
from src.acars import message_region_detection, ThresholdMethod, demod, parse_acars_message

# Symbol rate is always 2400 for ACARS
BD = 2400


def write_binary(message: bytearray, file_name: str) -> None:
    """
    Write the message to a binary file
    :param message: The bytearray to write to the file
    :param file_name: The name of the file to write to
    """
    with open(file_name, "wb") as binary_file:
        binary_file.write(message)


def process_gnu_radio_file():
    """
    Function to quickly setup up demodulating a specific file rather than worrying about good code structure
    """

    acars_file_path = os.path.join("data", "GNU_RADIO", "gr-acars_1.152M_2.bin")
    acars_samples = np.fromfile(acars_file_path, dtype=np.complex64)
    fs = 1.152e6

    samples_per_symbol = int(fs / BD)

    # Need to use rectified demodulator
    demodulated_samples = am_rectified_async_demodulate(acars_samples)

    # Experiment with cutoff 5-6 kHz
    filtered_samples = low_pass_filter(demodulated_samples, cutoff=5.5e3, fs=fs)

    plot_signal(filtered_samples, "Filtered Signal")

    # Decimate
    decimated_samples, fs, samples_per_symbol = decimate(
        filtered_samples, decimation_factor=8, fs=fs, samples_per_symbol=samples_per_symbol
    )

    plot_signal(decimated_samples, "Decimated Signal")

    new_fs = 48000

    # resample
    resampled_samples, samples_per_symbol = resampling.resample(
        decimated_samples, up=new_fs / 1e3, down=fs / 1e3, samples_per_symbol=samples_per_symbol
    )

    plot_signal(resampled_samples, "Resampled Signal")

    fs = new_fs

    # Extract the message with thresholding
    # Experiment with method, threshold factor, and window size
    left, right = message_region_detection(
        resampled_samples, threshold_method=ThresholdMethod.STD
    )

    message_samples = resampled_samples[left:right]

    message_samples = normalize_signal(message_samples)

    plot_signal(message_samples, "Message Signal")

    binary_bytes, hex_characters, message_keys, demod_message = demod(
        message_samples, fs=fs, samples_per_symbol=samples_per_symbol
    )

    print(f"HEX--->>: {hex_characters}")
    print(f"Message Keys--->>: {message_keys}")

    meta_info = parse_acars_message(demod_message)
    print(f"META--->>: {meta_info}")

    write_binary(demod_message, "gr_acars.demod")


def process_wikipedia_file():
    """
    Function to quickly setup up demodulating a specific file rather than worrying about good code structure
    """

    acars_file_path = os.path.join("data", "WIKIPEDIA", "Acars_sample.wav")
    fs, acars_samples = wavfile.read(acars_file_path)

    samples_per_symbol = int(fs / BD)

    # Convert to float32
    acars_samples = (acars_samples / 2 ** (16 - 1)).astype(np.float32)

    # Sample from Wikipedia is already AM Demodulated

    # Experiment with cutoff 5-6 kHz
    filtered_samples = low_pass_filter(acars_samples, cutoff=5.5e3, fs=fs)

    # Extract the message with thresholding
    # Experiment with method, threshold factor, and window size
    left, right = message_region_detection(
        filtered_samples, threshold_method=ThresholdMethod.STD, percentile=50
    )
    message_samples = filtered_samples[left:right]

    # Normalize the message samples
    message_samples = message_samples - np.mean(message_samples)
    message_samples = message_samples / np.max(np.abs(message_samples))

    binary_bytes, hex_characters, message_keys, demod_message = demod(
        message_samples, fs=fs, samples_per_symbol=samples_per_symbol, skip_index=1340
    )
    print(f"HEX--->>: {hex_characters}")
    print(f"Message Keys--->>: {message_keys}")

    meta_info = parse_acars_message(demod_message)
    print(f"META--->>: {meta_info}")

    write_binary(demod_message, "wikipedia_acars.demod")


def process_sigid_file():
    """
    Function to quickly setup up demodulating a specific file rather than worrying about good code structure
    """

    acars_file_path = os.path.join("data", "SIGID", "acars_IQ.wav")
    fs, acars_samples = wavfile.read(acars_file_path)

    # Extract the real and imaginary parts of the samples, since the file is split into two channels
    real_part = acars_samples[:, 0]
    imag_part = acars_samples[:, 1]

    # Combine the real and imaginary parts into a single complex array
    acars_samples = np.array(real_part + 1j * imag_part, dtype=np.complex64)

    # Need to use the rectified demodulator
    demodulated_samples = am_rectified_async_demodulate(acars_samples)

    # Experiment with cutoff 5-6 kHz
    filtered_samples = low_pass_filter(demodulated_samples, cutoff=5.5e3, fs=fs)

    new_fs = 48000

    # The sample rate of the sigid file isn't a clean multiple of 48000Hz so need to use a different resample method
    # Calculate new number of samples
    new_num_samples = int(len(filtered_samples) * (new_fs / fs))

    # Resample the data
    resampled_samples = resample(filtered_samples, new_num_samples)

    samples_per_symbol = int(new_fs / BD)

    message_regions = message_region_detection(
        resampled_samples, threshold_method=ThresholdMethod.STD
    )

    for index, message_region in enumerate(message_regions):
        # Extract the message using the indices detected
        message_samples = resampled_samples[message_region[0] : message_region[1]]

        # Normalize the message samples
        message_samples = normalize_signal(message_samples)

        binary_bytes, hex_characters, message_keys, demod_message = demod(
            message_samples, fs=new_fs, samples_per_symbol=samples_per_symbol
        )
        print(f"HEX--->>: {hex_characters}")
        print(f"Message Keys--->>: {message_keys}")

        meta_info = parse_acars_message(demod_message)
        print(f"META--->>: {meta_info}")

        write_binary(demod_message, f"sigid_acars{index}.demod")


def main():
    process_sigid_file()
    process_wikipedia_file()
    process_gnu_radio_file()


if __name__ == "__main__":
    main()

from enum import Enum

import numpy as np

from filters.fir_filter import low_pass_filter

class ThresholdMethod(str, Enum):
    STD = 'std'
    PERCENTILE = 'percentile'

class AcarsDemod:
    """
    A class for processing and decoding ACARS (Aircraft Communications Addressing and Reporting System) messages.

    This class provides methods for extracting, processing, and decoding ACARS messages from radio signals.
    It includes functionality for signal preprocessing, message extraction, and basic decoding of aircraft
    information and message sequences.

    Methods:
        parse_message(message): Parse and print meta information from a decoded ACARS message.
        acars_demod(signal, fs, samples_per_symbol): Demodulate an ACARS message from a signal (method not shown in the provided code snippet).

    The class is designed to work with numpy arrays for signal processing and assumes the input signals
    are from ACARS transmissions.
    """

    EXPECTED_KEYS = {
        "PREKEY": [1] * 16,
        "+": 0x2b,
        "*": 0x2a,
        "SYN": 0x16,
        "SOH": 0x01,
        "ETX": 0x03,
        "DEL": 0x7f,
    }


    def __init__(self):
        pass

    @staticmethod
    def parse_message(message: bytearray)-> str:
        """
        Parse and print meta information from a demodulated ACARS message.
        :param message: The demodulated ACARS message as a bytearray.
        :return: A string with the parsed meta information.
        """

        # # attempt libacars first
        # node = parse_acars_message(self.truncate_message(message), PyMsgDir.LA_MSG_DIR_UNKNOWN)
        # serialized_node = format_proto_tree(node, FormatMode.JSON)
        # node_json = json.loads(serialized_node)
        # acars_json = node_json.get('acars')
        # if not acars_json.get('err', True):
        #     return acars_json

        result = []

        aircraft = "Aircraft="
        aircraft += ''.join(chr(value) for value in message[6:13])
        result.append(aircraft)

        if len(message) >= 17:
            if message[17] == 0x02:
                result.append("STX")

            if len(message) >= 22:
                seq_no = "Seq. No="
                seq_no += ''.join(f"{value:02x} " for value in message[18:22])
                result.append(seq_no.strip())

                printable_chars = ''.join(
                    chr(value) if value >= 32 or value in [0x10, 0x13] else ''
                    for value in message[18:22]
                )
                if printable_chars:
                    result.append(printable_chars)

                if len(message) >= 28:
                    flight = "Flight="
                    flight += ''.join(chr(value) for value in message[22:28])
                    result.append(flight)

        final_output = '\n'.join(result)
        return final_output

    @staticmethod
    def truncate_message(message: bytearray) -> bytearray:
        """
        Truncate the message to the first occurrence of the DEL character and remove the beginning sync keys
        :param message: The message to truncate
        :return: The truncated message
        """

        index_01 = message.find(0x01)
        if index_01 != -1:
            message = message[index_01:]

        # Find the index of the first occurrence of \x7f and include it
        index_7f = message.find(0x7f)
        if index_7f != -1:
            message = message[:index_7f + 1]

        return message

    def detect_bytes(self, demod_message: bytearray) -> (list, list, list):
        """
        A function to analyze the bytes in the demodulated message to detect expected byte characters
        :param demod_message: The demodulated message
        Returns: A list of binary bytes, hex characters, and message keys
        """

        binary_bytes = []
        hex_characters = []
        message_keys = []
        for byte in demod_message:
            # Collect hex byte representation of the current byte
            hex_byte = format(byte, '02x').upper()
            print(f"Hex: {hex_byte}")
            # Collect binary byte representation of the current byte
            binary_byte = format(byte, '08b')
            print(f"Binary: {binary_byte}")
            binary_bytes.append(binary_byte)


            if byte in self.EXPECTED_KEYS.values():
                # Reverse Key Lookup
                key = list(self.EXPECTED_KEYS.keys())[list(self.EXPECTED_KEYS.values()).index(byte)]
                hex_characters.append(hex_byte)
                message_keys.append(key)

        return binary_bytes, hex_characters, message_keys

    @staticmethod
    def detect_noise(bytestream: bytearray, noise_threshold: int = 5) -> bool:
        """
        # Detect noise in the bytestream
        :param bytestream: The input bytestream to check for noise.
        :param noise_threshold: The threshold for noise detection.
        :return: True if noise is detected, False otherwise.
        """

        noise_count = 0
        for byte in bytestream:
            if byte == 0x00:
                noise_count += 1
                if noise_count > noise_threshold:
                    return True
            else:
                noise_count = 0
        return False

    def synchronize_and_extract_bits(
        self,
        fh_signal: np.ndarray,
        fl_signal: np.ndarray,
        skip_index: int = 200,
        samples_per_symbol: int = 20,
        clock_deviation: int = 5
    ) -> np.ndarray[int]:
        """
        Synchronizes the FH (2400Hz) signal and extracts bits by comparing FH and FL signals.
        :param fh_signal: The high-frequency signal.
        :param fl_signal: The low-frequency signal.
        :param skip_index: The starting index for synchronization.
        :param samples_per_symbol: The number of samples per symbol.
        :param clock_deviation: The deviation allowed for clock synchronization.
        :return: The extracted bits from the synchronized signal and the index of the last bit.
        """

        # Find FH (2400Hz) peak for synchronization
        # This is Symbol Synchronization
        fh_peak = np.max(fh_signal[skip_index:].real)

        # fh_peak_index = np.argmax(fh_signal[skip_index:].real)
        # plt.plot(fh_signal.real)
        # # Plot the vertical line at fh_peak_index
        # plt.axvline(x=fh_peak_index, color='r', linestyle='--', label=f'Peak Index: {fh_peak_index}')
        # # Plot the horizontal line at 50% of the peak
        # plt.axhline(y=fh_peak * 0.5, color='g', linestyle='--', label=f'50% of Peak: {fh_peak * 0.5}')
        # plt.title('50% FH Peak')
        # plt.legend()
        # plt.show()

        # Find start of payload after payload
        # about 50% of the peak value
        sample_index = next(
            index for index, value in enumerate(fh_signal[skip_index:].real, start=skip_index) if value <= 0.5 * fh_peak
        )

        # Move to the center of the first bit
        sample_index += samples_per_symbol // 2

        # Pre-allocation with numpy array is better for performance rather that appending to a list
        # Subtract off the samples we skipped but pad out a bit so we don't run into an index error
        bits = np.zeros((len(fh_signal) - sample_index) // samples_per_symbol + 1, dtype=int)

        # Index for bits array
        # Skip 0 index and leave as 0
        bit_index = 1

        # Needs to be in while loop to adjust the sample_index flexibly
        while sample_index < len(fh_signal) - 2 * samples_per_symbol:
            sample_index += samples_per_symbol

            # Compare FH and FL signals to set the bit value
            bits[bit_index] = 1 if fh_signal[sample_index].real > fl_signal[sample_index].real else 0
            bit_index += 1

            # Freq Synchronization based on FH signal
            sample_index = self.synchronize_signal(
                fh_signal,
                fl_signal,
                sample_index=sample_index,
                samples_per_symbol=samples_per_symbol,
                clock_deviation=clock_deviation,
                is_fh=True
            )

            # Freq Synchronization based on FL signal
            sample_index = self.synchronize_signal(
                fh_signal,
                fl_signal,
                sample_index=sample_index,
                samples_per_symbol=samples_per_symbol,
                clock_deviation=clock_deviation,
                is_fh=False
            )

        # noinspection PyTypeChecker
        return bits

    @staticmethod
    def synchronize_signal(
        fh_signal: np.ndarray,
        fl_signal: np.ndarray,
        sample_index: int,
        samples_per_symbol: int = 20,
        clock_deviation: int = 5,
        is_fh: bool = True):
        """
        Performs signal synchronization based on either the FH or FL signal.
        :param fh_signal: The high-frequency signal.
        :param fl_signal: The low-frequency signal.
        :param sample_index: The current index for synchronization.
        :param samples_per_symbol: The number of samples per symbol.
        :param clock_deviation: The deviation allowed for clock synchronization.
        :param is_fh: Whether the signal is high-frequency (fh) or low-frequency (fl).
        :return: The corrected sample index after synchronization.
        """

        # Flag specifies which signal to synchronize on so we can reuse the logic
        main_signal = fh_signal if is_fh else fl_signal
        alt_signal = fl_signal if is_fh else fh_signal

        # Check current bit, previous bit, and next bit to ensure there is a peak
        if (
            main_signal[sample_index].real > alt_signal[sample_index].real and
            alt_signal[sample_index + samples_per_symbol].real > main_signal[sample_index + samples_per_symbol].real and
            alt_signal[sample_index - samples_per_symbol].real > main_signal[sample_index - samples_per_symbol].real
        ):
            # Synchronize on the index between +/- 5 samples
            # Start at -5 samples
            peak = main_signal[sample_index - clock_deviation].real
            correction = -clock_deviation
            for num_samples in range(-clock_deviation + 1, clock_deviation + 1):  # -4 to 5 inclusive
                if main_signal[sample_index + num_samples].real > peak:
                    peak = main_signal[sample_index + num_samples].real
                    correction = num_samples
            # Adjust the sample index if a higher peak is found
            sample_index += correction
        return sample_index

    @staticmethod
    def nrzi_decode(bits_in: np.ndarray[int]) -> np.ndarray[int]:
        """
        Decode a Non-Return-to-Zero Inverted (NRZI) bitstream.
        :param bits_in: The input bitstream to decode.
        Returns: The decoded NRZI bitstream.
        """

        # Going to start on the 2nd index
        bit_index_out = 2

        # Pre-allocation with numpy array is better for performance rather that appending to a list
        bits_out = np.zeros(len(bits_in) + bit_index_out, dtype=int)

        # Decode the message with NRZI decoding
        # 2400 Hz or 1 says the bits are the same as the previous bit
        # 1200 Hz or 0 says the bits are different from the previous bit
        # Set the first two bits to 1
        bits_out[0:bit_index_out] = 1  # Sync on 1200 Hz
        prev_bit = 1
        for bit_in in bits_in:
            if bit_in == 0:
                bits_out[bit_index_out] = 1 - prev_bit
            else:
                bits_out[bit_index_out] = prev_bit
            prev_bit = bits_out[bit_index_out]
            bit_index_out += 1

        # noinspection PyTypeChecker
        return bits_out

    @staticmethod
    def pack_acars_bytes(bits_in: np.ndarray[int]) -> bytearray:
        """
        Pack the bits into bytes for the ACARS message. Note that for acars only the first 7 bits are packed.
        The 8th bit is ignored because it is a parity bit.
        :param bits_in: The bits to pack into bytes
        :return: The packed message as a bytearray
        """

        # Pre-allocation is better for performance rather than appending to a list
        message = bytearray(len(bits_in) // 8)

        for byte_index in range(0, len(bits_in) // 8):
            byte_value = 0
            for bit_position in range(7):  # Only consider the first 7 bits
                # bitwise OR operation and shift left
                # Yay, bitwise operations!
                byte_value |= bits_in[byte_index * 8 + bit_position] << bit_position
            message[byte_index] = byte_value

        return message

    def acars_demod(
        self,
        signal: np.ndarray[np.float32],
        fs: float = 48000.0,
        samples_per_symbol: int = 20,
        clock_deviation: int = 5,
        fl: int | float = 1200,
        fh: int | float = 2400,
        skip_index: int = 200
    ) -> (list, list, list, bytearray):
        """
        Demodulate an ACARS signal
        :param signal: The signal to demodulate
        :param fs: The sample rate of the signal
        :param samples_per_symbol: samples per symbol
        :param clock_deviation: Sample deviations for clock synchronization +/-5 samples
        :param fl: Low frequency for signal processing (default: 1200)
        :param fh: High frequency for signal processing (default: 2400)
        :param skip_index: Number of samples to skip at the beginning of the signal (default: 200)
        :return: The demodulated message
        """

        # Create 1200 Hz and 2400 Hz frequency kernels
        # np.exp(1j * theta) = cos(theta) + j * sin(theta)
        # 40 samples is a bit period or 2 symbol periods
        # Or 2 FH (2400Hz) period and 1 FL (1200Hz) period
        t = np.arange(40) / fs
        fh_kernel = np.exp(1j * t * fh * 2 * np.pi)
        fl_kernel = np.exp(1j * t * fl * 2 * np.pi)

        # Create a complex signal with the real part as the input signal and the imaginary part as 0
        signal = signal + 1j * 0

        # Convolve the signal with the fh (2400Hz) and fl (1200Hz) kernels in the time domain to correlate the frequency
        # components of the signal with the kernels
        fh_signal = np.convolve(signal, fh_kernel)
        fl_signal = np.convolve(signal, fl_kernel)

        # Low-pass filter to isolate fh and fl frequencies
        fh_signal = low_pass_filter(fh_signal, 3500, fs)
        fl_signal = low_pass_filter(fl_signal, 3500, fs)

        # Normalize the signal
        fh_signal /= np.max(np.abs(fh_signal))
        fl_signal /= np.max(np.abs(fl_signal))

        # Take the magnitude of the signal
        fh_signal[skip_index:].real = np.abs(fh_signal[skip_index:])
        fh_signal[skip_index:].imag = 0
        fl_signal[skip_index:].real = np.abs(fl_signal[skip_index:])
        fl_signal[skip_index:].imag = 0

        bits = self.synchronize_and_extract_bits(
            fh_signal=fh_signal,
            fl_signal=fl_signal,
            skip_index=skip_index,
            samples_per_symbol=samples_per_symbol,
            clock_deviation=clock_deviation
        )

        # keys_to_search = {
        #     "PREKEY": [1] * 16,
        #     "+": [0, 0, 1, 0, 1, 0, 1, 1],
        #     "*": [0, 0, 1, 0, 1, 0, 1, 0],
        #     "SYN": [0, 0, 1, 0, 1, 1, 0],
        #     "SOH": [0, 0, 0, 0, 0, 0, 1],
        #     "DEL": [0, 1, 1, 1, 1, 1, 1, 1],
        #     "ETX1": [1, 0, 0, 0, 0, 0, 1, 1],
        #     "ETX2": [0, 0, 0, 0, 0, 0, 1, 1]
        # }

        # Extracted bits are not yet in message format. Need to be NRZI decoded
        nrzi_decoded = self.nrzi_decode(bits)

        # Pack the bits into bytes being conscious of the 8th bit being a parity bit
        demod_message = self.pack_acars_bytes(nrzi_decoded)

        # This is more for debugging and visualization
        binary_bytes, hex_characters, message_keys = self.detect_bytes(demod_message)

        return binary_bytes, hex_characters, message_keys, demod_message

    @staticmethod
    def message_region_detection(
        signal: np.ndarray,
        threshold_method: ThresholdMethod = ThresholdMethod.STD,
        window_size: int = 100,
        percentile: int | float = 40
    ) -> (int, int):
        """
        Detect the region of the message in the signal using a thresholding method.
        :param signal: The input signal to detect the message region.
        :param threshold_method: The method to use for thresholding (STD or PERCENTILE).
        :param window_size: The size of the window for thresholding.
        :param std_factor: The standard deviation factor for thresholding if STD.
        :param percentile: The percentile for thresholding if PERCENTILE.
        :return: The start and end indices of the message region.
        """

        # Take the magnitude of the signal
        signal_amplitude = np.abs(signal)

        # Compute the threshold for message detection
        if threshold_method == ThresholdMethod.STD:
            # Use a rolling std deviation
            windows = np.lib.stride_tricks.sliding_window_view(signal_amplitude, window_size)
            message_region = np.std(windows, axis=-1)

            window_threshold = 0
        elif threshold_method == ThresholdMethod.PERCENTILE:
            threshold = np.percentile(signal_amplitude, percentile)
            message_region = signal_amplitude > threshold

            window_threshold = window_size * ((100 - percentile) / 100)
        else:
            raise ValueError("Invalid threshold method")

        # Smooth the threshold'd region to create hard boundaries
        smoothed_region = np.convolve(message_region.astype(int), np.ones(window_size), mode='same')

        # Convolution increases the amplitude
        # Window threshold is dynamic based on the thresholding method
        message_indices = np.where(smoothed_region > window_threshold)[0]

        # Find gaps in message_indices to segment regions
        regions = []
        if len(message_indices) > 0:
            start_index = message_indices[0]
            for i in range(1, len(message_indices)):
                # If there's a gap between current and previous index, mark the end of a region
                if message_indices[i] != message_indices[i - 1] + 1:
                    end_index = message_indices[i - 1]
                    regions.append((start_index, end_index))
                    start_index = message_indices[i]
            # Append the last region
            regions.append((start_index, message_indices[-1]))

        return regions

    @staticmethod
    def normalize_signal(signal: np.ndarray) -> np.ndarray:
        """
        Normalize a signal to +/- 1.
        :param signal: The input signal to normalize.
        :return: The normalized signal.
        """
        signal = signal - np.mean(signal)
        signal = signal / np.max(np.abs(signal))

        return signal

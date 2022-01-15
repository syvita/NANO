package org.syvita.i2p.nano;

import java.io.*;

//since I2P router monkey patches the default logger we must replace it again.
public class Logger {
	public static void log(String message) throws Exception {
	    BufferedWriter output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(FileDescriptor.out), "ASCII"), 512);
		output.write(message);
		output.write('\n');
		output.flush();
	}
}
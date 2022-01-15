package org.syvita.i2p.nano;

import java.io.PrintStream;
import java.util.Properties;
import java.util.stream.Collectors;

public class Main {
	public static void main(String[] args) throws Exception {
		if (TunnelControl.isPortInUse()) {
			Logger.log("NANO is already running");
			System.exit(1);
		}

		Logger.log("NANO has initiated, please wait several minutes for it to warm up...");

		Properties properties = new Properties();
		properties.put("router.sharePercentage", "80");

		// allow default properties to be added via command line args, e.g. --i2p.dir.base=/usr/share/i2p
		for(var arg: args) {
			if (arg.startsWith("--")) {
				String[] s = arg.split("=");
				
				String argName = s[0].substring("--".length());
				String argVal = s[1];
				
				properties.put(argName, argVal);
			}
		}

		RouterWrapper routerWrapper = new RouterWrapper(properties, () -> {});

		routerWrapper.start(() -> {});

		Runtime.getRuntime().addShutdownHook(new Thread(() -> {
			try {
				Logger.log("\nNANO is closing...");
			} catch(Exception e) {
			    e.printStackTrace();
			}
			
			routerWrapper.stop(true);
		}));

		new Thread(() -> {
			routerWrapper.waitForRouterRunning();
		}).start();
	}
}
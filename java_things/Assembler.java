import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
public class Assembler {
	public static void main(String[] args) throws IOException {
		try {
			String in = "code";
			String out ="machine";
			if (args.length == 2){
				in = args[0];
				out = args[1];
			}
			File f = new File(in + ".txt");
			File o = new File("out/" + out + ".txt");
			File o2 = new File("out/" + out + "_stripped.txt");
			BufferedReader b = new BufferedReader(new FileReader(f));
			BufferedWriter w = new BufferedWriter(new FileWriter(o));
			BufferedWriter w2 = new BufferedWriter(new FileWriter(o2));
			String readLine = "";
			System.out.println("Reading file using Buffered Reader");
			while ((readLine = b.readLine()) != null) {
				String[] line = readLine.toLowerCase().split(" ");
				String code = "";
				switch (line[0].toLowerCase()) {
					case "imme":
						code = "10";
						code += imme(line);
						break;
					case "blt":
						code = "110";
						code += branch(line);
						break;
					case "bne":
						code = "111";
						code += branch(line);
						break;
					case "add":
						code = "00000";
						code += rs_rt(line);
						break;
					case "addc":
						code = "00001";
						code += rs_rt(line);
						break;
					case "sub":
						code = "00010";
						code += rs_rt(line);
						break;
					case "subc":
						code = "00011";
						code += rs_rt(line);
						break;
					case "lsl":
						code = "00100";
						code += rs_rt(line);
						break;
					case "lslc":
						code = "00101";
						code += rs_rt(line);
						break;
					case "lsr":
						code = "00110";
						code += rs_rt(line);
						break;
					case "lsrc":
						code = "00111";
						code += rs_rt(line);
						break;
					case "asr":
						code = "01000";
						code += rs_rt(line);
						break;
					case "neg":
						code = "01001";
						code += rs_rt(line);
						break;
					case "and":
						code = "01010";
						code += rs_rt(line);
						break;
					case "or":
						code = "01011";
						code += rs_rt(line);
						break;
					case "cmp":
						code = "01110";
						code += rs_rt(line);
						break;
					case "lw":
						code = "01100";
						code += rs_rt(line);
						break;
					case "sw":
						code = "01101";
						code += rs_rt(line);
						break;
					case "alw":
						code = "0111110";
						code += register(line[1]);
						break;
					case "asw":
						code = "0111111";
						code += register(line[1]);
						break;
					case "halt":
						code = "01111000";
						code += line[1];
						break;
					default:
						break;
				}
				System.out.println(code + "\t\\\\ " + readLine);
				w.write(code + "\t\\\\" + readLine + "\n");
				if (!code.equals("")){
					w2.write(code + "\n");
				}
			}
			w.close();
			w2.close();
			b.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private static String register(String rx) {
		return to_bin(Integer.valueOf(rx.replaceAll("[^0-9]", "")), 2);
	}
	private static String rs_rt(String[] line) {
		String rs = register(line[1]);
		String rt = register(line[2]);
		return rt + rs;
	}
	private static String imme(String[] line) {
		// imme $r0 4 -> put LUT 4 into $r0
		String reg = register(line[1]);
		String imm = to_bin(Integer.valueOf(line[2].replaceAll("[^0-9]", "")), 5);
		return imm + reg;
	}
	private static String branch(String[] line) {
		// bne 32 -> (branch by 32nd lut entry)
		return to_bin(Integer.valueOf(line[1].replaceAll("[^0-9]", "")), 6);
	}
	private static String to_bin(int n, int bits) {
		String bin = Integer.toBinaryString(n);
		int rem = bits - bin.length();
		while (rem > 0) {
			rem--;
			bin = "0" + bin;
		}
		return bin;
	}
}

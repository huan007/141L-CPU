import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public class Programmer {
	private static final int C = 3;

	private static int CMP = 0;
	private static byte[] reg, creg;
	private static byte[] MEM; //0,1 -> 5,6; 64,65 -> 66,67; 130,131 -> 132, 133
	private static byte tempMem = 0x00;
	private static Integer[] immediates, branches;

	private static int PC = 0;
	private static String[] IM;
	private static Boolean halt = false;

	public static void main(String[] args) throws IOException {
		readin(args); // Fills IM
		run();
	}

	private static void imme(int rs, int imme) {
		reg[rs] = (byte) imme;
	}

	private static void blt(int branch) {
		if (CMP < 0) {
            // Jump by X
		}
	}

	private static void bne(int branch) {
		if (CMP != 0) {
            // Jump by X
		}
	}

	private static void add(int rs, int rt) {
		int val = reg[rs] + reg[rt];
		creg[C] = (byte)(val & 0x0100);
		reg[rs] = (byte)(val & 0x00FF);
	}

	private static void addc(int rs, int rt) {
		int val = reg[rs] + creg[rt];
		creg[C] = (byte)(val & 0x0100);
		reg[rs] = (byte)(val & 0x00FF);
	}

	private static void sub(int rs, int rt) {
		int val = reg[rs] - reg[rt];
		creg[C] = (byte)(val & 0x0100);
		reg[rs] = (byte)(val & 0x00FF);

	}

	private static void subc(int rs, int rt) {
		int val = reg[rs] - creg[rt];
		creg[C] = (byte)(val & 0x0100);
		reg[rs] = (byte)(val & 0x00FF);

	}

	private static void lsl(int rs, int rt) {
		int val = reg[rs] << reg[rt];
		creg[C] = (byte)(val & 0x0100);
		reg[rs] = (byte)(val & 0x00FF);

	}

	private static void lslc(int rs, int rt) {
		int val = 0;
		if (rt == C) {
			val = (reg[rs] << 1) | creg[C];
		}
		else {
			val = (reg[rs] << reg[rt]);
		}
		creg[C] = (byte)(val & 0x0100);
		reg[rs] = (byte)(val & 0x00FF);

	}

	private static void lsr(int rs, int rt) {
		int val = (reg[rs] & 0x00ff) >>> (reg[rt]  & 0x00ff);
		creg[C] = (byte)((reg[rs] & (0x01 << (reg[rt] - 1))) >>> (reg[rt] - 1));
		reg[rs] = (byte)(val & 0x00FF);
	}

	private static void lsrc(int rs, int rt) {
		int val = 0;
		if (rt == C) {
			val = (((reg[rs] & 0x00ff) >>> 1) | (creg[C] << 7) & 0x00ff)>>>7;
			creg[C] = (byte)(reg[rs] & 0x01);
		}
		else {
			val = (reg[rs] & 0x00ff) >>> (reg[rt]  & 0x00ff);
			creg[C] = (byte)((reg[rs] & (0x01 << (reg[rt] - 1))) >>> (reg[rt] - 1));
		}
		reg[rs] = (byte)(val & 0x00FF);
	}

	private static void asr(int rs, int rt) {
		int val = reg[rs] >> reg[rt];
		creg[C] = (byte)((reg[rs] & (0x01 << (reg[rt] - 1))) >>> (reg[rt] - 1));
		reg[rs] = (byte)(val & 0x00FF);
	}

	private static void cmp(int rs, int rt) {
		CMP = reg[rs] - reg[rt];
		creg[C] = 0;
	}

	private static void and(int rs, int rt) {
		reg[rs] &= reg[rt];
		creg[C] = 0;
	}

	private static void or(int rs, int rt) {
		reg[rs] |= reg[rt];
		creg[C] = 0;
	}

	private static void neg(int rs, int rt) {
		reg[rs] = (byte)(reg[rt] ^ (byte) 0xFF);
		creg[C] = 0;
	}

	private static void lw(int rs, int rt) {
		reg[rs] =
		creg[C] = 0;
	}

	private static void sw(int rs, int rt) {

		creg[C] = 0;
	}

	private static void alw(int rs) {
		reg[rs] = tempMem;
		creg[C] = 0;
	}

	private static void asw(int rs) {
		tempMem = reg[rs];
		creg[C] = 0;
	}

	private static void halt(int error) {
		halt = true;
		creg[C] = 0;
	}

	private static void fillMem() {

	}

	private static void test() { //0,1 -> 5,6; 64,65 -> 66,67; 130,131 -> 132, 133
		int i2f_i = MEM[0] << 8 | MEM[1];
		int i2f_f = MEM[5] << 8 | MEM[6];

		int f2i_f = MEM[64] << 8 | MEM[65];
		int f2i_i = MEM[66] << 8 | MEM[67];

		int add_a = MEM[128] << 8 | MEM[129];
		int add_b = MEM[130] << 8 | MEM[131];
		int add_res = MEM[132] << 8 | MEM[133];
	}

	private static void readin(String[] args) {
		try {
			Scanner sc = new Scanner(new File("immediates.txt"));

			File f = new File("code.txt");
			// BufferedReader b = new BufferedReader(new FileReader(f));
			ArrayList<Integer> L = new ArrayList<Integer>();
			ArrayList<String> SL = new ArrayList<String>();

			String readLine = "";

			reg = new byte[]{0,0,0,0};
			creg = new byte[]{0,1,7,0};
			MEM = new byte[140];

            // Write Immediate LUT
			while (sc.hasNextLine()) {
			  L.add(Integer.valueOf(sc.nextLine()));
			}
			immediates = L.toArray(new Integer[L.size()]);

            // // Write Branches LUT
			// sc = new Scanner(new File("branches.txt"));
			// L = new ArrayList<Integer>();
			// while (sc.hasNextLine()) {
			//   L.add(Integer.valueOf(sc.nextLine()));
			// }
			// branchess = L.toArray(new Integer[L.size()]);

            // Generate IM
			if (args.length == 2){
				f = new File(args[0]);
			}

			sc = new Scanner(f);
			while (sc.hasNextLine()) {
			  SL.add(sc.nextLine());
			}
			IM = SL.toArray(new String[SL.size()]);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	private static void run(){
		while (PC < IM.length && !halt) {
			parseline(IM[PC].split(" "));
			PC++;
		}
	}

	private static void parseline(String[] line) {
		switch (line[0]) {
			case "imme":
				imme(register(line[1]), immediate(line[2]));
				break;
			case "blt":
				blt(branch(line[1]));
				break;
			case "bne":
				bne(branch(line[1]));
				break;
			case "add":
				add(register(line[1]), register(line[2]));
				break;
			case "addc":
				addc(register(line[1]), register(line[2]));
				break;
			case "sub":
				sub(register(line[1]), register(line[2]));
				break;
			case "subc":
				subc(register(line[1]), register(line[2]));
				break;
			case "lsl":
				lsl(register(line[1]), register(line[2]));
				break;
			case "lslc":
				lslc(register(line[1]), register(line[2]));
				break;
			case "lsr":
				lsr(register(line[1]), register(line[2]));
				break;
			case "lsrc":
				lsrc(register(line[1]), register(line[2]));
				break;
			case "asr":
				asr(register(line[1]), register(line[2]));
				break;
			case "cmp":
				cmp(register(line[1]), register(line[2]));
				break;
			case "and":
				and(register(line[1]), register(line[2]));
				break;
			case "or":
				or(register(line[1]), register(line[2]));
				break;
			case "neg":
				neg(register(line[1]), register(line[2]));
				break;
			case "lw":
				lw(register(line[1]), register(line[2]));
				break;
			case "sw":
				sw(register(line[1]), register(line[2]));
				break;
			case "alw":
				alw(register(line[1]));
				break;
			case "asw":
				asw(register(line[1]));
				break;
			case "halt":
				halt(Integer.valueOf(line[1]));
				break;
			default:
				break;
		}
		System.out.printf("R0: %d\tR1: %d\tR2: %d\tR4: %d\tCout: %d\tCMP: %d\t\tCommand: %s\n", reg[0], reg[1], reg[2], reg[3], creg[C], CMP, line[0]);

	}

	private static int register(String rx) {
		return Integer.valueOf(str.replaceAll("[^0-9]", ""));
	}
	private static int immediate(String imm) {
		return immediates[Integer.valueOf(imm)];
	}
	private static int branch(String br) {
		return branches[Integer.valueOf(br)];
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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;
// import static org.joou.Unsigned.*;

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
		test();
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
		MEM = new byte[140];

		MEM[128] = (byte) 0b10111100;
		MEM[129] = 0b00000000;
		MEM[130] = (byte) 0b01000000;
		MEM[131] = 0b00000000;
		// MEM[128] = 0b00111100;
		// MEM[129] = 0b00000000;
		// MEM[130] = 0b00111100;
		// MEM[131] = 0b00000000;
		// 0 01111 0000000000 = 1
		// 0 01111 0000000001 = 1 + 2−10 = 1.0009765625 (next smallest float after 1)
		// 1 10000 0000000000 = −2
        //
		// 0 11110 1111111111 = 65504  (max half precision)
        //
		// 0 00001 0000000000 = 2−14 ≈ 6.10352 × 10−5 (minimum positive normal)
		// 0 00000 1111111111 = 2−14 - 2−24 ≈ 6.09756 × 10−5 (maximum subnormal)
		// 0 00000 0000000001 = 2−24 ≈ 5.96046 × 10−8 (minimum positive subnormal)
        //
		// 0 00000 0000000000 = 0
		// 1 00000 0000000000 = −0
        //
		// 0 11111 0000000000 = infinity
		// 1 11111 0000000000 = −infinity
        //
		// 0 01101 0101010101 = 0.333251953125 ≈ 1/3
	}

	private static void test() { //0,1 -> 5,6; 64,65 -> 66,67; 130,131 -> 132, 133
		// int i2f_i = MEM[0] << 8 | MEM[1];
		// int i2f_f = MEM[5] << 8 | MEM[6];
		// System.out.printf(Half(i2f_i).equals(Half(MEM[5], MEM[6])));
		// System.out.printf(Half(i2f_i));
		// System.out.printf(Half(i2f_i).toInt());
		// System.out.printf((Half(MEM[5], MEM[6])));
		// System.out.printf((Half(MEM[5], MEM[6]).toInt()));
        //
		// int f2i_f = MEM[64] << 8 | MEM[65];
		// String f2i_fs = String.format("%16s", Integer.toBinaryString(f2i_f)).replace(" ", "0");
		// // int f2i_i = MEM[66] << 8 | MEM[67];
		// System.out.printf(Half(f2i_fs).equals(Half(MEM[66], MEM[67])));
		// System.out.printf(Half(f2i_fs));
		// System.out.printf(Half(f2i_fs).toInt);
		// System.out.printf((Half(MEM[66], MEM[67])));
		// System.out.printf((Half(MEM[66], MEM[67]).toInt()));

		MEM[128] = (byte) 0b10111100;
		MEM[129] = 0b00000000;
		MEM[130] = (byte) 0b01000000;
		MEM[131] = 0b00000000;

		int add_a = 0x0000FFFF & (MEM[128] << 8 | MEM[129]);
		int add_b = 0x0000FFFF & (MEM[130] << 8 | MEM[131]);
		int add_r = MEM[132] << 8 | MEM[133];
		String add_as = String.format("%16s", Integer.toBinaryString(add_a)).replace(" ", "0");
		String add_bs = String.format("%16s", Integer.toBinaryString(add_b)).replace(" ", "0");
		String add_rs = String.format("%16s", Integer.toBinaryString(add_r)).replace(" ", "0");
		System.out.printf(add_as + ", " + add_bs+ ", " + add_rs + "\n");
		Half add_ah = new Programmer().new Half(add_as);
		Half add_bh = new Programmer().new Half(add_bs);
		Half add_res2 = new Programmer().new Half(MEM[132], MEM[133]);
		Half add_res = new Programmer().new Half(add_rs);
		Half res = add_ah.add(add_bh);
		System.out.printf("\n" + res.toString() + "\n");
		System.out.printf("\n" + add_res.toString() + "\n");
		System.out.printf("\n" + String.valueOf(res.equals(add_res)) + "\n");
		// System.out.printf((Programmer.Half(add_as).add(Programmer.Half(add_bs))).equals(Programmer.Half(MEM[132], MEM[133])));
		// System.out.printf((Programmer.Half(add_as).add(Programmer.Half(add_bs))));
		// System.out.printf((Programmer.Half(add_as).add(Programmer.Half(add_bs))).toInt());
		// System.out.printf((Programmer.Half(MEM[132], MEM[133])));
		// System.out.printf((Programmer.Half(MEM[132], MEM[133]).toInt()));
	}

	private static void readin(String[] args) {
		try {
			Scanner sc = new Scanner(new File("immediates_notes.txt"));
			// Scanner sc = new Scanner(new File("immediates.txt"));

			// File f = new File("code.txt");
			File f = new File("floatadd0.txt");
			// BufferedReader b = new BufferedReader(new FileReader(f));
			ArrayList<Integer> L = new ArrayList<Integer>();
			ArrayList<String> SL = new ArrayList<String>();

			String readLine = "";

			reg = new byte[]{0,0,0,0};
			creg = new byte[]{0,1,7,0};
			MEM = new byte[140];

            // Write Immediate LUT
			while (sc.hasNextLine()) {
			  L.add(Integer.valueOf((sc.nextLine()).split(" ")[0]));
			}
			immediates = L.toArray(new Integer[L.size()]);

            // Write Branches LUT
			// sc = new Scanner(new File("branches.txt"));
			sc = new Scanner(new File("branches_notes.txt"));
			L = new ArrayList<Integer>();
			while (sc.hasNextLine()) {
			  L.add(Integer.valueOf((sc.nextLine().split(" ")[0])));
			}
			branches = L.toArray(new Integer[L.size()]);

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
		switch (line[0].toLowerCase()) {
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
		return Integer.valueOf(rx.replaceAll("[^0-9]", ""));
	}
	private static int immediate(String imm) {
		return immediates[Integer.valueOf(imm.replaceAll("[^0-9]", ""))];
	}
	private static int branch(String br) {
		return branches[Integer.valueOf(br.replaceAll("[^0-9]", ""))];
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

	public class Half {
		private int sign;
		private int man;
		private int exp;
		private String bitstring;

		public Half() {}
		public Half(byte m, byte l) {
			System.out.printf("Generating from byte pair\n");
			sign = (m & 0x80) >> 7;
			exp = (m & 0x7c) >> 2;
			man = ((m & 0x03) << 3) | l;
			if (exp != 0) {
				man = man | 0x00000400;
			}
			bitstring = Integer.toBinaryString((m << 8) | l);
		}
		public Half(int i) {
			System.out.printf("Generating from int\n");
			this.sign = (0x00008000 & i) >> 15;
			int exp = 29;
			int bot14 = 0x00007FFF & i;
			while ((bot14 & 0x00008000) == 0 && exp >= 0) {
				System.out.printf("Shifting " + Integer.toBinaryString(bot14) + "\n");
				exp--;
				bot14 = bot14 << 1;
			}
			if ((bot14 & 0x00000008) != 0){
				if ((bot14 & 0x00000010) != 0 || (bot14 & 0x00000007) != 0) {
					bot14 += 8;
				}
			}
			if ((bot14 & 0x00008000) != 0) {
				bot14 = bot14 >> 1;
				exp++;
			}
			man = bot14 >> 4;
			this.man = man;
			this.exp = exp;
			String bits = "";
			bits += Integer.toBinaryString(this.sign);
			System.out.printf("Sign: %d\n", this.sign);
			bits += Integer.toBinaryString(exp);
			String manbits = Integer.toBinaryString(man);
			if (manbits.length() == 11) {
				manbits = manbits.substring(1,10);
			}
			while (manbits.length() < 10) {
				System.out.printf("Filling manbits" + manbits + "\n");
				manbits = "0" + manbits;
			}
			bits += manbits;
			this.bitstring = bits;
		}

		public Half(String bits) {
			System.out.printf("Generating from string" + bits + "\n");
			sign = Integer.parseInt(bits.substring(0, 1), 2);
			exp = Integer.parseInt(bits.substring(1, 6), 2);
			man = Integer.parseInt(bits.substring(7, 16), 2);
			if (exp != 0) {
				man |= 0x00000400;
			}
			System.out.printf("%s: %d, %s: %d, %s: %x\n", bits.substring(0, 1), sign, bits.substring(1, 6),  exp, bits.substring(6, 16), man);

			bitstring = bits;
		}

		public boolean equals(Half other) {
			System.out.printf("Stating equality" + "\n");
			System.out.printf("Sign: %d, %d \t Exp: %d, %d, Man:%x, %x \n", this.sign, other.sign, this.exp, other.exp, this.man, other.man);
			return this.sign == other.sign && this.exp == other.exp && this.man == other.man;
		}

		public byte[] getbytes() {
			byte[] ret = {0, 0};
			ret[0] = (byte) Byte.valueOf(bitstring.substring(0,8));
			ret[1] = (byte) Byte.valueOf(bitstring.substring(8,8));
			return ret;
		}

		public Half add(Half other) {
			System.out.printf("Adding " + this.bitstring + ", " +  other.bitstring + "\n");
			int a = this.toInt();
			System.out.printf("%d, %d,  %x\n", this.exp, a, a);
			int b = other.toInt();
			System.out.printf("%d, %d,  %x\n", other.exp, b, b);
			System.out.printf("%d, %d, %x, %x\n", a, b, a, b);
			if ((a & 0x00008000) == (b & 0x00008000)) {
				return new Half((a + b) | 0x00008000 & 0x0000FFFF);
			}
			else if ((a & 0x00007FFF) > (b & 0x00007FFF)) {
				return new Half(((a & 0x00007fff) - (b & 0x00007fff)) | (a & 0x00007FFF));
			}
			else {
				return new Half(((b & 0x00007fff) - (a & 0x00007fff)) | (b & 0x00007FFF));
			}
		}

		public String toString() {
			return bitstring;
		}

		public int toInt() {
			System.out.printf("Turning half to int, " + this.bitstring + "\n");
			man = (int) this.man;
			int res;
			if (this.exp > 28) {
				System.out.printf("Exp > 28\n");
				return 0x00017fff | (sign << 15);
			}
			else if (this.exp > 25) {
				System.out.printf("Exp > 25\n");
				return (man << (this.exp - 25)) | (sign << 15);
			}
			else if (this.exp == 25) {
				System.out.printf("Exp == 25\n");
				return man | (sign << 15);
			}
			else if (this.exp > 13) {
				System.out.printf("Exp > 13\n");
				res = man >>> (25 - this.exp);
				int r = man & (1 << (25 - this.exp - 1));
				int s = man - (res <<  (25 - this.exp));
				if (r != 0 && ((res & 0x1) != 0 || s != 0)){
					System.out.printf("rounding\n");
					res = res + 0x1;
				}
				return res | (sign << 15);
			}
			else {
				System.out.printf("Exp < 14\n");
				return 0x00010000 | (sign << 15);
			}
		}
	}
}

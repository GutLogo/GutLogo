import org.junit.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;
import org.nlogo.core.*;

public class onePatchTests {

	//instantiate the headless workspace 
	public HeadlessWorkspace ws;

	@Before
	public void setup(){
		//runs before the test, here it opens the example file with Netlogo Code
		ws = HeadlessWorkspace.newInstance();
		try {
			ws.open("../GutLogo.nlogo");
			ws.setDimensions(new WorldDimensions(0, 0, 0, 0, 12.0, false, true));
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}

	@After
	public void tearDown(){
		//runs after the test, gets rid of the workspace
		try {
			ws.dispose();
		}
		catch(Exception ex){
			ex.printStackTrace();
		}
	}

	@Test
	public void testAdd() {
		String str = "Junit is working fine";
		assertEquals("Junit is working fine",str);
	}

	@Test
	public void setStuckTest(){
		ws.command("set absorption 0");
		ws.command("set maxStuckChance 60");
		ws.command("set midStuckConc 1");
		ws.command("set initNumDesulfos 0");
		ws.command("set initNumBifidos 1");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set lowStuckBound 0");
		ws.command("setup");
		String actual = Dump.logoObject(ws.report("getStuckChance 0 "));
		assertEquals("30", actual);
	}

	@Test
	public void setAbsTest(){
		ws.command("set absorption 1");
		ws.command("set maxStuckChance 60");
		ws.command("set midStuckConc 1");
		ws.command("set initNumDesulfos 0");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 1");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set lowStuckBound 0");
		ws.command("setup");
		String actual = Dump.logoObject(ws.report("gettrueAbs "));
		assertEquals("0.723823204", actual);
	}

	@Test
	public void patchEatTest1(){
		ws.command("set absorption 0");
		ws.command("set initNumDesulfos 1");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("setup");
		ws.command("ask patches[ set CS 2 ]");
		ws.command("ask desulfo 0 [set result energy]");
		double start = Double.parseDouble(Dump.logoObject(ws.report("getResult ")));
		ws.command("ask patch 0 0 [patchEat]");
		ws.command("ask desulfo 0 [set result energy]");
		double next = Double.parseDouble(Dump.logoObject(ws.report("getResult ")));
		assertTrue(next<start);
		ws.command("ask desulfo 0 [set energy 50]");
		ws.command("ask desulfo 0 [set result energy]");
		double changed = Double.parseDouble(Dump.logoObject(ws.report("getResult ")));
		ws.command("ask patch 0 0 [patchEat]");
		ws.command("ask desulfo 0 [set result energy]");
		double end = Double.parseDouble(Dump.logoObject(ws.report("getResult ")));
		assertEquals(50 - (start-next), end-changed, .001);
	}

	@Test
	public void makeMetaTest1(){
		ws.command("set absorption 0");
		ws.command("set initNumDesulfos 1");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set inFlowCS 1");
		ws.command("setup");
		ws.command("ask patches[ set CS 2 ]");
		ws.command("set flowDist 0");
		ws.command("ask patch 0 0 [makeMetabolites]");
		ws.command("ask patch 0 0 [set result CS]");
		int result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(2, result);
	}

	@Test
	public void inConcTest1(){
		ws.command("set absorption 0");
		ws.command("set initNumDesulfos 1");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set inConcBifidos 1");
		ws.command("setup");
		ws.command("inConc");
		int result = Integer.parseInt(Dump.logoObject(ws.report("getNumBactLin 0 ")));
		assertEquals(2, result);
	}
}

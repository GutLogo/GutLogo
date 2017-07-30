import org.junit.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;
import org.nlogo.core.*;

public class flowDistTests {

	//instantiate the headless workspace 
	public HeadlessWorkspace ws;

	@Before
	public void setup(){
		//runs before the test, here it opens the example file with Netlogo Code
		ws = HeadlessWorkspace.newInstance();
		try {
			ws.open("../GutLogo.nlogo");
			ws.setDimensions(new WorldDimensions(0, 2, 0, 1, 12.0, false, true));
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
	public void makeMetaTest1(){
		ws.command("set absorption 0");
		ws.command("set initNumDesulfos 1");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set inFlowCS 0");
		ws.command("set reserveFraction 0");
		ws.command("setup");
		ws.command("ask patches[ set CS 2 ]");
		ws.command("set flowDist .5");
		ws.command("ask patches [storeMetabolites]");
		ws.command("ask patches [makeMetabolites]");
		ws.command("ask patch 1 0 [set result CS]");
		int result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(2, result);
	}

	@Test
	public void makeMetaTest2(){
		ws.command("set absorption 0");
		ws.command("set initNumDesulfos 1");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set inFlowCS 2");
		ws.command("set reserveFraction 0");
		ws.command("setup");
		ws.command("ask patches[ set CS 0 ]");
		ws.command("set flowDist .5");
		ws.command("ask patches [storeMetabolites]");
		ws.command("ask patches [makeMetabolites]");
		ws.command("ask patch 0 0 [set result CS]");
		int result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(1, result);
		ws.command("ask patch 0 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(1, result);
	}

	@Test
	public void makeMetaTest3(){
		ws.command("set absorption 0");
		ws.command("set initNumDesulfos 1");
		ws.command("set initNumBifidos 0");
		ws.command("set initNumClosts 0");
		ws.command("set initNumBacteroides 0");
		ws.command("set seedPercent 0");
		ws.command("set inFlowCS 12");
		ws.command("set reserveFraction 0");
		ws.command("setup");
		ws.command("ask patches[ set CS 0 ]");
		ws.command("set flowDist 1.5");
		ws.command("ask patches [storeMetabolites]");
		ws.command("ask patches [makeMetabolites]");
		ws.command("ask patch 0 0 [set result CS]");
		int result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(4, result);
		ws.command("ask patch 0 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(4, result);
		ws.command("ask patch 1 0 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(2, result);
		ws.command("ask patch 1 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(2, result);
		ws.command("ask patch 2 0 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(0, result);
		ws.command("ask patch 2 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(0, result);
		ws.command("ask patches [storeMetabolites]");
		ws.command("ask patches [makeMetabolites]");
		ws.command("ask patch 0 0 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(4, result);
		ws.command("ask patch 0 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(4, result);
		ws.command("ask patch 1 0 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(4, result);
		ws.command("ask patch 1 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(4, result);
		ws.command("ask patch 2 0 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(3, result);
		ws.command("ask patch 2 1 [set result CS]");
		result = Integer.parseInt(Dump.logoObject(ws.report("getResult ")));
		assertEquals(3, result);
	}


}

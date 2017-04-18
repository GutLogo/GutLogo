import org.junit.Test;
import static org.junit.Assert.assertEquals;

import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;

public class Tests {

	String proc = "to-report flatten-tree [x]\n"
		+ "  ifelse is-list? x\n"
		+ "    [ report reduce [sentence ?1 ?2] fput [] map [flatten-tree ?] x ]\n"
		+ "    [ report (list x) ]\n"
		+ "end";

	HeadlessWorkspace ws = HeadlessWorkspace.newInstance();
	ws.openFromSource(emptyModel);

	@After
	public void tearDown(){
		ws.dispose();
	}

	public void test(String input, String expected) {
		val actual = Dump.logoObject(ws.report("flatten-tree " + input));
		assertEquals(expected, actual);
	}

	@Test
	public void testAdd() {
		String str = "Junit is working fine";
		assertEquals("Junit is working fine",str);
	}

	@Test
	public void empty(){
		test("[]", "[]"); 
	}
	@Test
	public void flat(){
		test("[1 2 3]", "[1 2 3]");
	}
	@Test 
	public void nested(){
		test("[[1] [2] [3]]", "[1 2 3]");
	}
	@Test
	public void nestedEmpties(){
		test("[[] [] []]", "[]"); 
	}
	@Test
	public void deeplyNested(){
		test("[[[[[[[1]]]]]]]", "[1]");
	}
	@Test public void complex(){
		test("[1 [[[2]] 3 [] [[[] 4] [[5]]] 6 [7]] 8]","[1 2 3 4 5 6 7 8]"); 
	}
}

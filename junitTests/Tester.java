import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class Tester {

  String emptyModel = Utils.getResourceAsString("/resources/system/empty.nlogo");

  String proc = "to-report flatten-tree [x]\n"
                + "  ifelse is-list? x\n"
                + "    [ report reduce [sentence ?1 ?2] fput [] map [flatten-tree ?] x ]\n"
                + "    [ report (list x) ]\n"
                + "end";
 
  HeadlessWorkspace ws = HeadlessWorkspace.newInstance();
  ws.openFromSource(emptyModel);

  @After
	public tearDown(){
		ws.dispose();
	}

  public test(String input, String expected) {
    val actual = Dump.logoObject(ws.report("flatten-tree " + input));
    assertEquals(expected, actual);
  }

  @Test def empty() { test("[]", "[]"); }
  @Test def flat() { test("[1 2 3]", "[1 2 3]"); }
  @Test def nested() { test("[[1] [2] [3]]", "[1 2 3]"); }
  @Test def nestedEmpties() { test("[[] [] []]", "[]"); }
  @Test def deeplyNested() { test("[[[[[[[1]]]]]]]", "[1]"); }
  @Test def complex() { test("[1 [[[2]] 3 [] [[[] 4] [[5]]] 6 [7]] 8]",
                             "[1 2 3 4 5 6 7 8]"); }

} 

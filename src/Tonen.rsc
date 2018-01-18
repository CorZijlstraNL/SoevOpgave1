module Tonen

import vis::Figure;
import vis::Render;

public Figure maakProject(int scale){

c=false;
projectBox=box(size(scale),fillColor(Color () { return c ? color("red") : color("green"); }),onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }),resizable(false));
return projectBox;
}

public Figure maakDirectory(int scale){

directoryBox=box(size(scale),fillColor("red"),resizable(false));

return directoryBox;

}



public void toonTest(){

int n=100;
    	
Figure scaledbox(){
   int n = 100;
   return vcat([ hcat([ scaleSlider(int() { return 0; },     
                                    int () { return 200; },  
                                    int () { return n; },    
                                    void (int s) { n = s; }, 
                                    width(400)),
                        text(str () { return "n: <n>";})
                      ], left(),  top(), resizable(false)),  
                 computeFigure(Figure (){ return tree(maakProject(n),
          [ maakDirectory(n),
     	    maakDirectory(n)
     	  ],
          std(size(50)), std(gap(20))
    	); })
               ]);
}
render(scaledbox());  
}

public void toonGrafiek(){


p1 = maakProject(100);
t1 = tree(maakProject(100),
          [ maakDirectory(100),
     	    box(fillColor("blue"))
     	  ],
          std(size(50)), std(gap(20))
    	);
render(t1);



}
public void testMouse(){
c = false; 
b = box(fillColor(Color () { return c ? color("red") : color("green"); }),
	onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; })
	,shrink(0.5));
render(b);
}

public void hscreenTest(){
i = hcat([box(fillColor("red"),project(text(s),"hscreen")) | s <- ["a","b","c","d"]],top());
sc = hscreen(i,id("hscreen"));
render(sc);
}

public void layerTest(){
nodes = [ box(text("A"), id("A"), fillColor("lightBlue"), layer("A")), 
          box(text("B"), id("B"), fillColor("lightBlue"), layer("B")), 
          box(text("C"), id("C"), fillColor("lightBlue"), layer("C")), 
          box(text("A1"), id("A1"), fillColor("lightGreen"), layer("A")), 
          box(text("B1"), id("B1"), fillColor("lightGreen"), layer("B")), 
          box(text("C1"), id("C1"), fillColor("lightGreen"), layer("C"))
        ];
edges = [ edge("A", "B"), edge("B", "C")];
render(graph(nodes, edges, gap(200), std(size(100))));
}



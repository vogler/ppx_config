.PHONY: all clean

all:
	ocamlbuild -use-ocamlfind main.native

clean:
	ocamlbuild -clean

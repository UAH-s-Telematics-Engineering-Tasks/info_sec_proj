all: clean
	pdflatex Report.tex
	bibtex Report.aux
	pdflatex Report.tex
	pdflatex Report.tex

.PHONY: clean

clean:
	rm -f *.aux *.toc *.bbl *.blg *.log *.out

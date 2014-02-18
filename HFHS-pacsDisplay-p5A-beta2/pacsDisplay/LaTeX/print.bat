xelatex -jobname=manual "\input{readme.tex}"
xelatex -jobname=manual "\input{readme.tex}"
move manual.pdf ..\manual

xelatex -jobname=install "\includeonly{sections/install}\input{readme.tex}"
xelatex -jobname=install "\includeonly{sections/install}\input{readme.tex}"
move install.pdf ..\manual\sections

xelatex -jobname=applications "\includeonly{sections/applications}\input{readme.tex}"
xelatex -jobname=applications "\includeonly{sections/applications}\input{readme.tex}"
move applications.pdf ..\manual\sections

xelatex -jobname=lumresponse "\includeonly{sections/lumresponse}\input{readme.tex}"
xelatex -jobname=lumresponse "\includeonly{sections/lumresponse}\input{readme.tex}"
move lumresponse.pdf ..\manual\sections

xelatex -jobname=lutgen "\includeonly{sections/lutgen}\input{readme.tex}"
xelatex -jobname=lutgen "\includeonly{sections/lutgen}\input{readme.tex}"
move lutgen.pdf ..\manual\sections

xelatex -jobname=loadlut "\includeonly{sections/loadlut}\input{readme.tex}"
xelatex -jobname=loadlut "\includeonly{sections/loadlut}\input{readme.tex}"
move loadlut.pdf ..\manual\sections

xelatex -jobname=lutlibrary "\includeonly{sections/lutlibrary}\input{readme.tex}"
xelatex -jobname=lutlibrary "\includeonly{sections/lutlibrary}\input{readme.tex}"
move lutlibrary.pdf ..\manual\sections

xelatex -jobname=edid "\includeonly{sections/edid}\input{readme.tex}"
xelatex -jobname=edid "\includeonly{sections/edid}\input{readme.tex}"
move edid.pdf ..\manual\sections

del *.log
del *.toc
del *.out
del *.aux
del sections\*.aux
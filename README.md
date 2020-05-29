# Paper2: adaptation between child-directed and child speech

## First notes

### CHILDES reader
The CHILDES reader is revised for extracting the speech\
Check the local code file. Revised part marked as "This is where I start to play"

### A couple of corrected errors in the Manchester corpus
Session _Nicole 020806.xml_: age corrected from 07M12D to 08M06D
Session _Nicole 020730.xml_: age corrected from 08M29D to 07M30D

### Why/How merging?
Maxiamlly enriching the data for _Word2Vec_ while preserving enough data points on the timeline (>=10). Hence, sessions of 3 months are merged each time.\

#### Vocabulary size (frequency > 1) for each merged dataset
##### Child-directed speech
|Name|Age|Vocabulary|
| --- | --- |
|Anne|24|741|
|Anne|25|845|
|Anne|26|925|
|Anne|27|861|
|Anne|28|972|
|Anne|29|865|
|Anne|30|922|
|Anne|31|925|
|Anne|32|947|
|Anne|33|1043|
|Aran|25|844|
|Aran|26|963|
|Aran|27|1042|
|Aran|28|1042|
|Aran|29|1128|
|Aran|30|1067|
|Aran|31|1227|
|Aran|32|1275|
|Aran|33|1241|
|Aran|34|1240|
|Aran|35|1171|
|Becky|26|721|
|Becky|27|788|
|Becky|28|786|
|Becky|29|821|
|Becky|30|762|
|Becky|31|767|
|Becky|32|666|
|Becky|33|751|
|Becky|34|740|
|Becky|35|810|
|Carl|23|707|
|Carl|24|703|
|Carl|25|719|
|Carl|26|664|
|Carl|27|689|
|Carl|28|729|
|Carl|29|682|
|Carl|30|628|
|Carl|31|612|
|Carl|32|646|
|Dominic|25|723|
|Dominic|26|752|
|Dominic|27|759|
|Dominic|28|794|
|Dominic|29|861|
|Dominic|30|854|
|Dominic|31|821|
|Dominic|32|799|
|Dominic|33|741|
|Dominic|34|763|
|Dominic|35|680|
|Gail|26|956|
|Gail|27|1033|
|Gail|28|989|
|Gail|29|946|
|Gail|30|870|
|Gail|31|914|
|Gail|32|1032|
|Gail|33|971|
|Gail|34|932|
|Gail|35|936|
|Joel|25|929|
|Joel|26|1017|
|Joel|27|995|
|Joel|28|943|
|Joel|29|1028|
|Joel|30|1007|
|Joel|31|1104|
|Joel|32|1100|
|Joel|33|1128|
|Joel|34|1057|
|John|25|680|
|John|26|772|
|John|27|773|
|John|28|749|
|John|29|731|
|John|30|742|
|John|31|768|
|John|32|782|
|John|33|827|
|John|34|844|
|John|35|821|
|Liz|25|710|
|Liz|26|773|
|Liz|27|778|
|Liz|28|807|
|Liz|29|821|
|Liz|30|791|
|Liz|31|731|
|Liz|32|708|
|Liz|33|665|
|Liz|34|697|
|Liz|35|582|
|Nicole|27|912|
|Nicole|28|869|
|Nicole|29|922|
|Nicole|30|920|
|Nicole|31|1036|
|Nicole|32|928|
|Nicole|33|1021|
|Nicole|34|948|
|Nicole|35|996|
|Nicole|36|954|
|Ruth|25|657|
|Ruth|26|773|
|Ruth|27|775|
|Ruth|28|830|
|Ruth|29|803|
|Ruth|30|876|
|Ruth|31|831|
|Ruth|32|875|
|Ruth|33|899|
|Ruth|34|963|
|Ruth|35|903|
|Ruth|36|787|
|Warren|24|745|
|Warren|25|881|
|Warren|26|948|
|Warren|27|1013|
|Warren|28|995|
|Warren|29|964|
|Warren|30|938|
|Warren|31|930|
|Warren|32|937|
|Warren|33|904|
|Warren|34|864|
##### Child speech
|Name|Age|Vocabulary|
| --- | --- |
|Anne|24|412|
|Anne|25|482|
|Anne|26|531|
|Anne|27|467|
|Anne|28|557|
|Anne|29|539|
|Anne|30|562|
|Anne|31|545|
|Anne|32|543|
|Anne|33|649|
|Aran|25|355|
|Aran|26|413|
|Aran|27|454|
|Aran|28|446|
|Aran|29|477|
|Aran|30|446|
|Aran|31|538|
|Aran|32|564|
|Aran|33|581|
|Aran|34|597|
|Aran|35|568|
|Becky|26|399|
|Becky|27|479|
|Becky|28|512|
|Becky|29|588|
|Becky|30|541|
|Becky|31|592|
|Becky|32|508|
|Becky|33|593|
|Becky|34|574|
|Becky|35|647|
|Carl|23|406|
|Carl|24|408|
|Carl|25|443|
|Carl|26|460|
|Carl|27|503|
|Carl|28|562|
|Carl|29|556|
|Carl|30|545|
|Carl|31|541|
|Carl|32|552|
|Dominic|25|340|
|Dominic|26|375|
|Dominic|27|410|
|Dominic|28|428|
|Dominic|29|474|
|Dominic|30|515|
|Dominic|31|525|
|Dominic|32|553|
|Dominic|33|520|
|Dominic|34|520|
|Dominic|35|405|
|Gail|26|480|
|Gail|27|527|
|Gail|28|517|
|Gail|29|527|
|Gail|30|522|
|Gail|31|567|
|Gail|32|598|
|Gail|33|558|
|Gail|34|503|
|Gail|35|488|
|Joel|25|391|
|Joel|26|528|
|Joel|27|522|
|Joel|28|504|
|Joel|29|529|
|Joel|30|573|
|Joel|31|687|
|Joel|32|755|
|Joel|33|765|
|Joel|34|770|
|John|25|310|
|John|26|378|
|John|27|421|
|John|28|397|
|John|29|409|
|John|30|416|
|John|31|434|
|John|32|481|
|John|33|517|
|John|34|525|
|John|35|449|
|Liz|25|414|
|Liz|26|486|
|Liz|27|519|
|Liz|28|521|
|Liz|29|528|
|Liz|30|542|
|Liz|31|531|
|Liz|32|531|
|Liz|33|518|
|Liz|34|523|
|Liz|35|445|
|Nicole|27|269|
|Nicole|28|270|
|Nicole|29|330|
|Nicole|30|383|
|Nicole|31|472|
|Nicole|32|451|
|Nicole|33|481|
|Nicole|34|465|
|Nicole|35|499|
|Nicole|36|518|
|Ruth|25|93|
|Ruth|26|102|
|Ruth|27|110|
|Ruth|28|186|
|Ruth|29|230|
|Ruth|30|314|
|Ruth|31|328|
|Ruth|32|380|
|Ruth|33|424|
|Ruth|34|473|
|Ruth|35|509|
|Ruth|36|459|
|Warren|24|329|
|Warren|25|406|
|Warren|26|449|
|Warren|27|533|
|Warren|28|554|
|Warren|29|544|
|Warren|30|559|
|Warren|31|607|
|Warren|32|613|
|Warren|33|575|
|Warren|34|515|

#### Further control for vocabulary
A fixed ratio? It makes sense now since vocabulary is not always increasing, and the difference is lower, downplaying the role of difference in such an extreme manner makes sense now. TRADEOFF!

## Merge sessions and measure vocabulary size
<pre><code>python3 vocab_stats.py</code></pre>

####Arguments
--reg
--merge_size
--min_count

## Training
<pre><code>PYTHONHASHSEED=1 python3 training.py</code></pre>

####Argument
--reg:	"child" or "cds"

## Measure
<pre><code>python3 betweenness.py</code></pre>

####Argument
--reg:	"child" or "cds"


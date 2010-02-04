#some sed recipies to make sure that xml is nice n friendly
s/</\&lt;/g
s/>/\&gt;/g
s/\&/\&amp;/g
s/"/\&quot;/g
s/'/\&#39;/g

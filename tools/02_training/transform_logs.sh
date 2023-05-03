cat 1000-1000-20220303-logtrain.json|grep '"instance_id":"web"'>web-1000-1000-20220303-logtrain.json
cat 1000-1000-20220304-logtrain.json|grep '"instance_id":"web"'>web-1000-1000-20220304-logtrain.json

cat 1000-1000-20220303-logtrain.json|grep '"instance_id":"ratings"'>ratings-1000-1000-20220303-logtrain.json
cat 1000-1000-20220304-logtrain.json|grep '"instance_id":"ratings"'>ratings-1000-1000-20220304-logtrain.json

cat 1000-1000-20220303-logtrain.json|grep '"instance_id":"catalog"'>catalog-1000-1000-20220303-logtrain.json
cat 1000-1000-20220304-logtrain.json|grep '"instance_id":"catalog"'>catalog-1000-1000-20220304-logtrain.json


cat web-1000-1000-20220303-logtrain.json > 1000-1000-20220303-logtrain.json
cat ratings-1000-1000-20220303-logtrain.json >> 1000-1000-20220303-logtrain.json
cat catalog-1000-1000-20220303-logtrain.json >> 1000-1000-20220303-logtrain.json

cat web-1000-1000-20220304-logtrain.json > 1000-1000-20220304-logtrain.json
cat ratings-1000-1000-20220304-logtrain.json >> 1000-1000-20220304-logtrain.json
cat catalog-1000-1000-20220304-logtrain.json >> 1000-1000-20220304-logtrain.json



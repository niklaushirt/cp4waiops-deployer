# Create Synthetic Metrics

Dumps existing tables and creates synthetic metrics.



```bash
./create-synthetic-metrics-data.sh
```

Go through the steps.

The metrics generation starts for 14 days back from current date.



# Train the model in AI Manager

# Metrics Inception

Creates synthetic metric anomalies for 
- cpu.user_usage
- memory.used_percentage

for pod `qotd-rating (qotd/qotd-rating-76d4964f5-8l8z6):::7QthWgdy4IaSS0KkxFUkYmBCLC0?`


You can change this in the files in the `inception` directory.


```bash
./inception-metrics.sh
```


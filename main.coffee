fs = require("fs")
csv = require("csv")
dateFormat = require('dateFormat')

inFile = process.argv[2]
outFile = "#{inFile}-out.csv"
splits = '100,200,500'.split ','
outColumns = "month,date,debit,>#{splits.join ',>'},credit,description,balance".split ','

splitsReversed = splits.slice(0).reverse()
lastMonth = null

csv().from.path(inFile,
		columns: 'date,amount,,,description,,balance,'.split ','
	)
	.transform((row) ->
		month = dateFormat(row.date, 'mmm')
		if month != lastMonth
			row.month = lastMonth = month
		row[if row.amount < 0 then 'debit' else 'credit'] = row.amount
		for limit in splitsReversed
			if row.amount < limit * -1
				row[">#{limit}"] = row.amount
				break
		row
	)
	.to.path(outFile,
		columns: outColumns
		header: true
	)
	.on('end', (count) -> console.log "Wrote #{count} lines to #{outFile}")
	.on('error', (error) -> console.log error.message)

# Output:
# #0 ["2000-01-01","20322051544","1979.0","8.8017226E7","ABC","45"]
# #1 ["2050-11-27","28392898392","1974.0","8.8392926E7","DEF","23"]
# Number of lines: 2
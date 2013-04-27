Every time I visit Portland, I spend hours in [Powell's Books](powells.com) - multiple visits to their multiple locations, and many hours of shopping. I spend ages going through the shelves, trying to remember what I wanted and opening up my phone to compare the prices to the cheapest used price I could get it for on Amazon.

This year, I figured I could be more efficient.

I scraped my Amazon wishlist data and used the Powell's API to get their prices and store locations (including section and shelf location, even!) for all the books on my Amazon wishlist, then stuck all that in MongoDB. Then I selected only those books that are sufficiently cheaper at Powell's as to be worth lugging home in my suitcase, and organized those by location in the store(s).

TODO: Plan an optimal route through the various Powell's locations to pick them up while I'm there.
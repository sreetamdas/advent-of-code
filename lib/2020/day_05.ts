const calculateSeat = (input: string) => {
	const row = parseInt(
		input.slice(0, 7).replaceAll("F", "0").replaceAll("B", "1"),
		2
	);
	const col = parseInt(
		input.slice(7).replaceAll("L", "0").replaceAll("R", "1"),
		2
	);
	return [row, col];
};

const getSeatID = (input: string[]) => {
	let highestSeatID = 0,
		seatIDs: number[] = [],
		lastID = 0;
	input.forEach((line) => {
		const [row, col] = calculateSeat(line);

		const seatID = row * 8 + col;
		seatIDs.push(seatID);

		if (seatID > highestSeatID) highestSeatID = seatID;
	});

	seatIDs
		.sort((a, b) => a - b)
		.forEach((seat) => {
			if (seat === lastID + 2) {
				console.log(`Part two: ${seat - 1}`);
			}
			lastID = seat;
		});
	return `Part one: ${highestSeatID}`;
};

// https://codesandbox.io/s/compassionate-dream-q6s5i?file=/src/index.ts
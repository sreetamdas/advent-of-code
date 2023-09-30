const moveSquares = (
	count: [number, number],
	matrix: string[],
	curr: [number, number],
	[x, y]: [number, number]
): [boolean, [number, number]] => {
	const newPos: [number, number] = [
		Math.floor(curr[0] + count[0]),
		curr[1] + count[1]
	];
	if (newPos[0] >= x) newPos[0] %= x;

	const isTree = matrix[newPos[1]][newPos[0]] === "#";
	return [isTree, newPos];
};

const countTrees = (input: string) => {
	const rows = input.split("\n");
	const width = rows[0].length,
		height = rows.length;

	let current: [number, number] = [0, 0];

	let treeCount = 0;
	while (current[1] < height - 2) {
		const [isTree, newPos] = moveSquares([3, 1], rows, current, [
			width,
			height
		]);

		if (isTree) {
			treeCount += 1;
		}
		current = newPos;
	}
	return treeCount;
};
                            
// https://codesandbox.io/s/brave-faraday-7wm9z?file=/src/index.ts
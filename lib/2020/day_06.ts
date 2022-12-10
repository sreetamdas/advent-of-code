const second = (input: string[]) => {
	let set = new Set(input[0]);
	input.forEach((_person, i) => {
		if (i < input.length - 1)
			set = new Set([...set].filter((a) => new Set(input[i + 1]).has(a)));
	});
	return set.size;
};

const getCount = (input: string) => {
	const normalized = input.replaceAll("\n", "").replace(/(.)(?=.*\1)/g, "");
	return [...normalized].length;
};

const calculate = (input: string) => {
	let total = 0,
		total2 = 0;
	const groups = input.split("\n\n");
	groups.forEach((group) => {
		const count = getCount(group);
		total += count;
		const count2 = second(
			group.split("\n").filter((person) => person.length <= 26)
		);
		total2 += count2;
	});

	return [total, total2];
};
                                                              
// https://codesandbox.io/s/magical-hermann-3hnmv?file=/src/index.ts
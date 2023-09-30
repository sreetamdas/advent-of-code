const OURS = "shiny gold";

const createMap = (input: string[]) => {
	const map: Object = input.reduce((map, rule) => {
		const [outer, inner] = rule
			.replaceAll(".", "")
			.replaceAll("bags", "")
			.replaceAll("bag", "")
			.trim()
			.split("contain");
		const innerBags: string[] = inner
			.split(",")
			.map((entry) => entry.trim());

		// console.log(innerBags);

		return { ...map, [outer.trim()]: innerBags };
	}, {});
	return map;
};

const findBags = (input: string, allBags: Object, alreadyDone = []) => {
	let count = 0;
	Object.keys(allBags).forEach((outer) => {
		// console.log(outer, allBags[outer]);

		if (allBags[outer].indexOf(input) > -1) {
			if (alreadyDone && alreadyDone.includes(outer)) return 0;
			count += 1;
			alreadyDone.push(outer);
			// other bags
			const otherCount = findBags(outer, allBags, alreadyDone);
			count += otherCount;
		}
	});
	// console.log(count);
	return count;
};

const countInnerBags = (bags: Object, bag: string) => {
	if (!bags[bag]) {
		return 0;
	}
	let innerBags = 0;
	for (const innerBag of bags[bag]) {
		innerBags +=
			innerBag[0] + innerBag[0] * countInnerBags(bags, innerBag[1]);
	}
	return innerBags;
};

const get = (input: string) => {
	const rules = input.split("\n");
	const map = createMap(rules);

	const res1 = findBags(OURS, map);

	let bags = {};

	for (const line of rules) {
		let innerBagTypes = line.replace(/.*?bags/, "").split(",");

		innerBagTypes = innerBagTypes.map((x) => [
			Number(x.replace(/[^\d]+/g, "")),
			x
				.replace(/(bags|bag)/, "")
				.replace(/.*\d /, "")
				.replace(/[^a-zA-Z ]/g, "")
				.trim()
		]);
		bags[line.replace(/bags.*/, "").trim()] = innerBagTypes;
	}

	return countInnerBags(bags, OURS);
};

// https://codesandbox.io/s/jovial-firefly-h5cnj?file=/src/index.ts
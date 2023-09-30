const checkMap = (map: string) => {
	return map.split("").every((int) => int === "0" || int === "1");
};

const updateMap = (str: string, index: number) => {
	return str.substr(0, index) + `${+str[index] + 1}` + str.substr(index + 1);
};

const getMap = (length: number) => {
	return Array.from(Array(length), () => "0").join("");
};

const makeMove = (move: string, counter: number): [number, number] => {
	const [type, count_] = move.split(" ");
	const sign = count_[0] === "-" ? -1 : 1;
	const count = +count_.slice(1) * sign;

	// console.log(type, count);
	if (type === "nop") return [counter, 1];
	if (type === "acc") return [counter + count, 1];
	if (type === "jmp") return [counter, count];

	return [counter, count];
};

const get_part_1 = (input: string) => {
	const instructions = input.split("\n");
	let map = getMap(instructions.length);

	let counter = 0,
		i = 0,
		last = 0;

	while (checkMap(map)) {
		last = counter;
		const move = instructions[i];
		const [counter_, index] = makeMove(move, counter);

		counter = counter_;
		map = updateMap(map, i);
		i += index;
	}

	return last;
};

// https://codesandbox.io/s/friendly-antonelli-d7y2o?file=/src/index.ts

const get_part2 = (input) => {
	const instructions = input.split("\n").map((line) => {
		// @ts-ignore
		const [, operation, value] = /(\w+) ([+-]\d+)/.exec(line.trim());

		return [operation, parseInt(value)];
	});

	for (let i = 0; i < instructions.length; i++) {
		const patched = instructions.map(([operation, value]) => [
			operation,
			value,
		]);

		if (instructions[i][0] === "jmp") {
			patched[i][0] = "nop";
		} else if (instructions[i][0] === "nop") {
			patched[i][0] = "jmp";
		} else {
			continue;
		}

		const executed = new Set();

		let acc = 0;
		let p = 0;

		while (!executed.has(p)) {
			executed.add(p);

			const [operation, argument] = patched[p];

			switch (operation) {
				case "acc":
					acc += argument;
					p++;

					break;
				case "jmp":
					p += argument;

					break;
				case "nop":
					p++;

					break;
			}

			if (p >= patched.length) {
				return acc;
			}
		}
	}
};

// https://codesandbox.io/s/wild-microservice-sqrq5?file=/src/index.ts

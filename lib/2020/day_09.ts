const PREV = 5;

const findContiguousSumRange = (num: number, data: number[]) => {
	let l = -1;
	for (let m = 0; m < data.length; m++) {
		l++;
		for (let i = 3; i < data.length - 3; i++) {
			let j = data.slice(m, l + i);
			let el = j.reduce((a, b) => a + b);
			if (el === num) {
				console.log(Math.min(...j), Math.max(...j));
				i = data.length;
			} else if (el > num) {
				i = data.length;
			}
		}
	}
};

const checkIfSumOf = (num: number, input: number[]) => {
	const res = input.some((str) => {
		if (input.indexOf(num - str) > -1) return true;
		return false;
	});
	return res;
};

const get = (input: string) => {
	const lines = input.split("\n").map(Number);
	lines.slice(PREV).forEach((num, index) => {
		const check = checkIfSumOf(num, lines.slice(index, index + PREV));

		if (!check) {
			console.log(num);
			findContiguousSumRange(num, lines.slice(0, index));
		}
	});
};

// https://codesandbox.io/s/relaxed-shaw-ot4wo?file=/src/index.ts
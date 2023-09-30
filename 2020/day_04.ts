const REQUIRED_FIELDS = [
	"byr",
	"iyr",
	"eyr",
	"hgt",
	"hcl",
	"ecl",
	"pid"
	// "cid"
];

const replaceAtIndex = (s: string, x: string, index: number) => {
	return s.substring(0, index) + x + s.substring(index + 1);
};

const checkIfValidValue = (index: number, value: string) => {
	if (index === 0) {
		return (
			value.match(/^\d{4}$/) &&
			Number(value) >= 1920 &&
			Number(value) <= 2002
		);
	}
	if (index === 1) {
		return (
			value.match(/^\d{4}$/) &&
			Number(value) >= 2010 &&
			Number(value) <= 2020
		);
	}
	if (index === 2) {
		return (
			value.match(/^\d{4}$/) &&
			Number(value) >= 2020 &&
			Number(value) <= 2030
		);
	}
	if (index === 3) {
		if (value.slice(-2) === "cm")
			return (
				Number(value.slice(0, -2)) >= 150 &&
				Number(value.slice(0, -2)) <= 193
			);
		if (value.slice(-2) === "in")
			return (
				Number(value.slice(0, -2)) >= 59 &&
				Number(value.slice(0, -2)) <= 76
			);
		return false;
	}
	if (index === 4) {
		return value[0] === "#" && value.slice(1).match(/^[a-f0-9]{6}$/);
	}
	if (index === 5) {
		return ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].includes(
			value
		);
	}
	if (index === 6) {
		return value.match(/^\d{9}$/);
	}
};

const checkIsValid = (input: string) => {
	const fields: string[] = input.replaceAll("\n", " ").split(" ");
	if (fields.length < REQUIRED_FIELDS.length) return false;

	let fieldPresentMap = "00000000";

	fields.forEach((fieldEntry) => {
		const key = fieldEntry.split(":")[0];
		const index = REQUIRED_FIELDS.indexOf(key);

		if (index > -1 && !checkIfValidValue(index, fieldEntry.split(":")[1]))
			return false;

		if (index > -1) {
			const toReplace = (Number(fieldPresentMap[index]) + 1).toString();
			fieldPresentMap = replaceAtIndex(fieldPresentMap, toReplace, index);
		} else return false;
	});

	if (fieldPresentMap.slice(0, -1).indexOf("0") > -1) return false;

	return true;
};

const getValidPasspors = (input: string) => {
	let count = 0;
	const entries = input.split("\n\n");
	console.log(entries.length);

	entries.forEach((entry) => {
		if (checkIsValid(entry)) {
			count += 1;
		}
	});

	return count;
};
        
// https://codesandbox.io/s/dazzling-galois-vjiw0?file=/src/index.ts
#Abdulla Al Harun

import random
import re


def roll_dice(num_dice: int, sides: int, modifier: int = 0) -> int:
    """Roll the dice and return the total with modifier."""
    rolls = [random.randint(1, sides) for _ in range(num_dice)]
    total = sum(rolls) + modifier
    print(f"\n🎲 You rolled: {', '.join(map(str, rolls))}")
    print(f"Modifier: {modifier:+d}")
    print(f"Total: {total}")
    return total


def parse_dice_notation(notation: str):
    """Parse a string like '3d6+2' or '2d20-5'."""
    match = re.fullmatch(r"\s*(\d+)\s*d\s*(\d+)\s*([+-]\s*\d+)?\s*", notation)
    if not match:
        raise ValueError("Invalid dice notation. Example: 3d6+2")
    num_dice = int(match.group(1))
    sides = int(match.group(2))
    modifier = int(match.group(3).replace(" ", "")) if match.group(3) else 0
    return num_dice, sides, modifier


def get_user_input():
    """Prompt the user for dice parameters."""
    print("\n--- Dice Roller ---")
    print("You can enter notation like '3d6+2' or input manually.\n")

    choice = input("Enter dice notation (or press Enter for manual mode): ").strip()
    if choice:
        return parse_dice_notation(choice)

    # Manual input mode
    num_dice = int(input("Number of dice (1–9): "))
    sides = int(input("Sides per die (2–32): "))
    mod_sign = input("Modifier sign (+ or -): ").strip()
    mod_value = int(input("Modifier value (0–99): "))
    modifier = mod_value if mod_sign == "+" else -mod_value
    return num_dice, sides, modifier


def validate(num_dice: int, sides: int, modifier: int):
    if not (1 <= num_dice <= 9):
        raise ValueError("Number of dice must be between 1 and 9.")
    if not (2 <= sides <= 32):
        raise ValueError("Sides per die must be between 2 and 32.")
    if not (-99 <= modifier <= 99):
        raise ValueError("Modifier must be between -99 and 99.")


def main():
    while True:
        try:
            num_dice, sides, modifier = get_user_input()
            validate(num_dice, sides, modifier)
            roll_dice(num_dice, sides, modifier)
        except Exception as e:
            print(f"⚠️  Error: {e}")

        again = input("\nRoll again? (y/n): ").strip().lower()
        if again != "y":
            print("\nThanks for playing! 🎉")
            break


if __name__ == "__main__":
    main()

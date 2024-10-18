mod utils;

use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet() {
    alert("Hello, {{project-name}}!");
}

#[wasm_bindgen]
pub fn sum3(x: i32, y: i32, z: i32) -> i32 {
    x + y + z
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let x = super::sum3(1, 2, 3);
        assert_eq!(x, 6);
    }
}

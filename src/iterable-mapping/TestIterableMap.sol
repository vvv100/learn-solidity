// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IterableMap.sol";

contract TestIterableMap {
    using IterableMap for IterableMap.Map;
    
    IterableMap.Map private map;

    function test() external {
        map.put(address(0), 0);
        map.put(address(1), 100);
        map.put(address(2), 200); // insert
        map.put(address(2), 200); // update
        map.put(address(3), 300);

        for (uint i = 0; i < map.size(); i++) {
            address key = map.getKeyByIndex(i);

            assert(map.get(key) == i * 100);
        }

        map.remove(address(1));

        // keys = [address(0), address(3), address(2)]
        assert(map.size() == 3);
        assert(map.getKeyByIndex(0) == address(0));
        assert(map.getKeyByIndex(1) == address(3));
        assert(map.getKeyByIndex(2) == address(2));
    }
}
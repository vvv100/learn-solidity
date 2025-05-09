// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library IterableMap {

    struct Map {
        // keys arrays
        address[] keys;

        // key value pairs 
        mapping(address => uint) values;

        // mapping from key to keys array index for fast delete key O(1)
        mapping(address => uint) keyIndex;

        // key is inserted
        mapping(address => bool) inserted;

    }

    function size(Map storage _map) external returns (uint) {
        return _map.keys.length;
    }

    function put(Map storage _map, address _key, uint _value) external {
        if (_map.inserted[_key]) {
            _map.values[_key] = _value;
        } else {
            _map.keys.push(_key);
            _map.values[_key] = _value;
            _map.keyIndex[_key] = _map.keys.length - 1;
            _map.inserted[_key] = true;
        }
    }

    function getKeyByIndex(Map storage _map, uint _index) external returns (address) {
        return _map.keys[_index];
    }

    function get(Map storage _map, address _key) external returns (uint) {
        return _map.values[_key];
    }

    function remove(Map storage _map, address _key) external {
        if (!_map.inserted[_key] || _map.keys.length == 0) {
            return;
        }

        uint removeKeyIndex = _map.keyIndex[_key];
        address lastKey = _map.keys[_map.keys.length - 1];
        uint lastKeyIndex = _map.keyIndex[lastKey];

        _map.keys[removeKeyIndex] = lastKey;
        _map.keyIndex[lastKey] = removeKeyIndex;

        _map.keys.pop();
        delete _map.values[_key];
        delete _map.inserted[_key];
        delete _map.keyIndex[_key];
    }


}
return {
    Driver = Core.resolveDriver(),
    Builder = require('core.query.builder'),
    Model = require('core.model.base'),
    Migration = require('core.migration'),
    Grammar = require('core.query.grammar'),
    GitHub = require('core.util.github'),
    fs = require('core.util.fs'),
}
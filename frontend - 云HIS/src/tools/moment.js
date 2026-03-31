function dateState() {
    let date = new Date();
    if (date.getHours() >= 6 && date.getHours() < 12) {
        return '上午'
    } else if (date.getHours() >= 12 && date.getHours() < 18) {
        return '下午'
    } else {
        return '晚上'
    }
};

function setDayNight() {
    let date = new Date();
    if (date.getHours() >= 6 && date.getHours() < 18) {
        return '白天'
    } else {
        return '晚上'
    }
};

const dayFormat = 'YYYY-MM-DD';
const timeFormat = 'HH:mm:ss';
const dateFormat = 'YYYY-MM-DD HH:mm:ss';
const hourFormat = 'HH:mm';

export {
    dateState,
    setDayNight,
    dayFormat,
    timeFormat,
    dateFormat,
    hourFormat
};
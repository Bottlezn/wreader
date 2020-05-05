package wang.wangzh.wreader.utils;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * @author wangzh
 * @date 2020/2/22 14:49
 */
public class GsonUtil {
    public static Gson gson = new Gson();

    /**
     * 实体类转化为json
     *
     * @param bean
     * @return
     */
    public static String bean2json(Object bean) {
        return gson.toJson(bean);
    }

    /**
     * @param <T>
     * @param json
     * @param type 转化的目标实体类
     * @return
     */
    public static <T> T json2bean(String json, Type type) throws JsonSyntaxException {
        return gson.fromJson(json, type);
    }

    /**
     * json数组转list
     *
     * @param json       数据源，json格式
     * @param memberName 数组元素的名称
     * @param type
     * @param <T>
     * @return
     */
    public static <T> List<T> jsonArray2List(String json, String memberName, Type type) {
        List<T> list = new ArrayList<>();
        JsonArray jsonArray = new JsonParser().parse(json).getAsJsonObject().getAsJsonArray(memberName);
        if (jsonArray == null) {
            return Collections.emptyList();
        }
        for (int i = 0; i < jsonArray.size(); i++) {
            JsonObject obj = jsonArray.get(i).getAsJsonObject();
            list.add((T) json2bean(obj.toString(), type));
        }
        return list;
    }
}

